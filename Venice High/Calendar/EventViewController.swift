//
//  EventViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 1/24/18.
//  Copyright © 2018 steets250. All rights reserved.
//

import Alamofire
import Alamofire_Synchronous
import EventKit
import JGProgressHUD
import MWFeedParser
import PermissionScope
import PMAlertController
import SwiftTheme
import SwiftWebVC
import SwipeCellKit
import UserNotifications

class EventViewController: UITableViewController {
    var searchController: UISearchController!
    var searchBar: UISearchBar!
    var hud: JGProgressHUD!
    var feedParser: MWFeedParser!

    var error = false
    var loaded = false
    var firstRun = true
    var articleCount: Int!
    var articlesTemp = [Article]()
    var articlesSorted = [ArticleGroup]()
    var articlesVisible = [ArticleGroup]()
    var extras = [Event]()
    var countTemp = [MWFeedItem]()
    var currentText: String = ""
    var searching: Bool = false
    var current: Date!
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var lastReturned = 0
    var swipeFunctions: SwipeFunctions!

    override func viewDidLoad() {
        super.viewDidLoad()

        swipeFunctions = SwipeFunctions(self)
        extras = appDelegate.eventData

        Setup.page(self, title: "Upcoming Events", leftButton: UIBarButtonItem(image: UIImage(named: "Help"), style: .plain, target: self, action: #selector(openHelp)), rightButton: UIBarButtonItem(image: UIImage(named: "Calendar"), style: .plain, target: self, action: #selector(openVisual)), largeTitle: true, back: true)

        pageSetup()
        visualSetup()
        hudSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        if loaded == false {
            loaded = true
            initialLoad()
        }
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if searchController != nil {
            searchController.isActive = false
        }
        if searchBar != nil {
            searchBar.text = nil
            currentText = ""
            searching = false
            searchBar.setShowsCancelButton(false, animated: false)
            searchBar.endEditing(true)
            refreshData()
        }
    }

    func hudSetup() {
        if defaults.bool(forKey: "Is Dark") {
            hud = JGProgressHUD(style: .light)
        } else {
            hud = JGProgressHUD(style: .dark)
        }
        hud.textLabel.text = "Loading Events"
        hud.detailTextLabel.text = "0% Complete"
        hud.parallaxMode = .device
        hud.interactionType = .blockAllTouches
        hud.indicatorView = JGProgressHUDRingIndicatorView()
        hud.progress = 0.0
        hud.show(in: self.appDelegate.window!.rootViewController!.view)
    }

    func pageSetup() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        searchBar.placeholder = "Search Events"
        searchBar.delegate = self

        definesPresentationContext = true

        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.searchController = searchController
        } else {
            self.tableView.tableHeaderView = searchBar
        }

        let backgroundView = UIView()
        backgroundView.theme_backgroundColor = ThemeColorPicker(keyPath: "Global.imageBackgroundColor")

        let backgroundImage = UIImageView(frame: view.frame)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.alpha = 1 / 3
        backgroundImage.contentMode = .scaleAspectFill
        backgroundView.addSubview(backgroundImage)

        tableView.backgroundView = backgroundView
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "eventCell")
        tableView.backgroundColor = .clear

        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(dataCheck), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl!)
        }
    }

    func visualSetup() {
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexColor = appDelegate.themeBlue
        self.view.theme_backgroundColor = ThemeColorPicker(keyPath: "Global.imageBackgroundColor")

        searchController.searchBar.theme_keyboardAppearance = ThemeKeyboardAppearancePicker(keyPath: "UISearchBar.keyboardAppearance")
        searchController.searchBar.theme_barStyle = ThemeBarStylePicker(keyPath: "UISearchBar.barStyle")
        let textFieldInsideSearchController = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchController?.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")

        searchBar.theme_keyboardAppearance = ThemeKeyboardAppearancePicker(keyPath: "UISearchBar.keyboardAppearance")
        searchBar.theme_barStyle = ThemeBarStylePicker(keyPath: "UISearchBar.barStyle")
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
    }

    @objc func openVisual() {
        let test = defaults.array(forKey: "titleArray") ?? []
        if test.isEmpty == false {
            self.navigationController?.pushViewController(VisualViewController(), animated: true)
        }
    }

    @objc func openHelp() {
        AlertScope.showAlert(.eventViewController, self)
    }

    @objc func initialLoad() {
        let test = defaults.array(forKey: "titleArray") ?? []
        if internet() {
            if test.isEmpty == false {
                articlesTemp = loadArticles()
                processArray()
                hud.dismiss(afterDelay: 0)
                tableView.reloadData()
                dataCheck()
            } else {
                loadCount()
            }
        } else {
            hud.dismiss(afterDelay: 0)
            endRefresh()
            if test.isEmpty == false {
                articlesTemp = loadArticles()
                processArray()
                tableView.reloadData()
            } else {
                loaded = false
                let alertController = PMAlertController(title: "No Network", message: "Please connect your phone to a wifi or cellular network.", preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
                alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    @objc func dataCheck() {
        DispatchQueue.global(qos: .background).async {
            let apiURL1 = URL(string: "https://venicehs-lausd-ca.schoolloop.com/cms/rss?d=x&group_id=1442645854073&types=_assignment__event_&return_url=1494562389332")!
            let response1 = AppDelegate.Manager.request(apiURL1).responseString()
            let data1 = response1.value ?? ""
            let apiURL2 = URL(string: "https://raw.githubusercontent.com/steets250/Venice-High-App-Database/master/Events.json")!
            let response2 = AppDelegate.Manager.request(apiURL2).responseString()
            let data2 = response2.value ?? ""

            DispatchQueue.main.async {
                var change = true
                let fullData = data1 + data2
                if fullData != "" {
                    let newHash = String(describing: fullData.utf8.md5)
                    if let oldHash = self.defaults.string(forKey: "Event Hash") {
                        if oldHash == newHash {
                            change = false
                        } else {
                            self.defaults.set(newHash, forKey: "Event Hash")
                        }
                    } else {
                        self.defaults.set(newHash, forKey: "Event Hash")
                    }
                }
                if change {
                    self.loadCount()
                } else {
                    self.endRefresh()
                }
            }
        }
    }

    func daysBetweenDates(startDate: Date, endDate: Date) -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let components = calendar.components([.day], from: startDate, to: endDate, options: [])
        return components.day!
    }

    func loadCount() {
        firstRun = true
        DispatchQueue.global(qos: .background).async {
            self.request()
            DispatchQueue.main.async {
                self.countTemp = []
                self.loadData()
            }
        }
    }

    func loadData() {
        DispatchQueue.global(qos: .background).async {
            self.request()
            DispatchQueue.main.async {
                self.processArray()
                self.hud.dismiss(afterDelay: 0)
                self.endRefresh()
                self.tableView.reloadData()
                self.defaults.set(Date(), forKey: "Last Refreshed")
            }
        }
    }

    func endRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { self.refreshControl!.endRefreshing() })
    }
}

extension EventViewController /*TableView Methods*/ {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articlesVisible[indexPath.section].articles[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        if article.link != "" {
            if defaults.bool(forKey: "Is Dark") {
                let webVC = SwiftModalWebVC(urlString: article.link, theme: .dark, dismissButtonStyle: .arrow)
                present(webVC, animated: true, completion: nil)
            } else {
                let webVC = SwiftModalWebVC(urlString: article.link)
                present(webVC, animated: true, completion: nil)
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return months[articlesVisible[section].month - 1]
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var temp = [String]()
        articlesVisible = articlesVisible.sorted(by: { $0.month < $1.month })
        articlesVisible = articlesVisible.sorted(by: { $0.year < $1.year })
        for i in articlesVisible {
            temp.append(months[i.month - 1].getFirst(3))
            temp.append(" ")
            if articlesVisible.count < 12 {
                temp.append(" ")
            }
        }
        if articlesVisible.count > 0 {
            temp.remove(at: temp.count - 1)
            if articlesVisible.count < 12 {
                temp.remove(at: temp.count - 1)
            }
        }
        return temp
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if title != " " {
            lastReturned = index / 3
            return index / 3
        } else {
            return lastReturned
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        if defaults.bool(forKey: "Is Dark") {
            view.tintColor = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)
            header.textLabel?.textColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
        } else {
            view.tintColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
            header.textLabel?.textColor = .black
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return articlesVisible.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesVisible[section].articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = articlesVisible[indexPath.section].articles[indexPath.row]
        let aCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        aCell.selectionStyle = .none
        aCell.backgroundColor = .clear
        aCell.delegate = self
        aCell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 18.0)
        if article.link == "" {
            aCell.selectionStyle = .none
        }
        aCell.titleLabel.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        if article.startDate == article.endDate {
            let dateString = formatter.string(from: article.startDate)
            if defaults.bool(forKey: "🅱️") {
                aCell.titleLabel.text = String(dateString.dropLast(3)) + ": " + "🅱️" + String(article.title.dropFirst())
            } else {
                aCell.titleLabel.text = String(dateString.dropLast(3)) + ": " + article.title
            }
        } else {
            let startString = formatter.string(from: article.startDate)
            let endString = formatter.string(from: article.endDate)
            if defaults.bool(forKey: "🅱️") {
                aCell.titleLabel.text = startString.dropLast(3) + "-" + endString.dropLast(3) + ": " + "🅱️" + String(article.title.dropFirst())
            } else {
                aCell.titleLabel.text = startString.dropLast(3) + "-" + endString.dropLast(3) + ": " + article.title
            }
        }

        if !(article.startTime == "none" && article.endTime == "none")
            && !(article.startTime == "12:00 AM" && article.endTime == "11:55 PM")
            && !(article.startTime == "12:00 AM" && article.endTime == "11:59 PM") {
            aCell.titleLabel.text = aCell.titleLabel.text! + " from " + article.startTime.lowercased() + " to " + article.endTime.lowercased()
        }
        return aCell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77
    }
}

extension EventViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            currentText = text
            searching = true
            refreshData()
        } else {
            searching = false
            refreshData()
        }
        tableView.reloadData()
    }

    func refreshData() {
        articlesVisible = articlesSorted
        var tempResults = [Article]()
        if searching && currentText != "" {
            for group in articlesSorted {
                if group.articles.isEmpty == false {
                    for article in group.articles {
                        if article.title.lowercased().contains(currentText.lowercased()) {
                            tempResults.append(article)
                        }
                    }
                }
            }
            articlesVisible = processArticles(tempResults)
        }
        tableView.reloadData()
    }
}

extension EventViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searching = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        currentText = ""
        searching = false
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        refreshData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "🅱️" {
            defaults.set(!(defaults.bool(forKey: "🅱️")), forKey: "🅱️")
        }
        searchBar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentText = searchText
        refreshData()
    }
}

extension EventViewController: MWFeedParserDelegate {
    func request() {
        let URL = Foundation.URL(string: "https://venicehs-lausd-ca.schoolloop.com/cms/rss?d=x&group_id=1442645854073&types=_assignment__event_&return_url=1494562389332")
        feedParser = MWFeedParser(feedURL: URL)!
        feedParser.delegate = self
        feedParser.parse()
    }

    func feedParserDidStart(_ parser: MWFeedParser) {
        if firstRun {
            self.countTemp = [MWFeedItem]()
        } else {
            self.articlesTemp = [Article]()
        }
    }

    func feedParserDidFinish(_ parser: MWFeedParser) {
        if error == false {
            if firstRun {
                articleCount = countTemp.count
                firstRun = false
            } else {
                saveArticles(articlesTemp)
            }
        } else {
            loaded = false
        }
    }

    func feedParser(_ parser: MWFeedParser, didParseFeedItem item: MWFeedItem) {
        if firstRun {
            countTemp.append(item)
        } else {
            let (temp, start, end) = getDates(website: item.link)
            if temp == "error" {
                loaded = false
                error = true
                feedParser.stopParsing()
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: { self.hud.dismiss(); self.endRefresh() })
                if internet() == false {
                    let alertController = PMAlertController(title: "No Network", message: "Please connect your phone to a wifi or cellular network.", preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
                    alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = PMAlertController(title: "Loading Error", message: "Please reload the application to refresh the calendar feed.", preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
                    alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                let dateString = temp
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy"
                let date = dateFormatter.date(from: dateString)!
                articlesTemp.append(Article(title: item.title, link: item.link, startDate: date, endDate: date, startTime: start, endTime: end, calendar: nil, alert: nil))
                let numerator = Float(articlesTemp.count)
                let denominator = Float(articleCount)
                hud.progress = numerator / denominator
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: { self.hud.detailTextLabel.text = "\(Int((numerator / denominator) * 100))% Complete" })
            }
        }
    }

    func getDates(website: String) -> (String, String, String) {
        var html: String!
        let myURLString = website
        let myURL = URL(string: myURLString)!
        do {
            html = try String(contentsOf: myURL, encoding: .ascii)
            return (html.slice(from: "<div class=\"date\">", to: "</div>") ?? "error", html.slice(from: "<b>Start Time:</b> ", to: "</td>") ?? "none", html.slice(from: "<b>End Time:</b> ", to: "</td>") ?? "none")
        } catch let error {
            print("Error: \(error)")
            return ("error", "error", "error")
        }
    }
}

extension EventViewController /*Data Processing*/ {
    func processArray() {
        articlesTemp = importManual(articlesTemp)
        articlesTemp = articlesTemp.sorted(by: { $0.title.compare($1.title) == .orderedAscending })
        articlesTemp = articlesTemp.sorted(by: { swipeFunctions.dateAndTime(date: $0.startDate, time: $0.startTime).compare(swipeFunctions.dateAndTime(date: $1.startDate, time: $1.startTime)) == .orderedAscending })
        articlesTemp = removeOld(articlesTemp)
        articlesTemp = mergeDuplicates(articlesTemp)
        articlesSorted = processArticles(articlesTemp)
        articlesVisible = articlesSorted
    }

    func stringToDate(_ input: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.date(from: input)!
    }

    func importManual(_ input: [Article]) -> [Article] {
        var articles = input
        if extras.isEmpty == false {
            for event in extras {
                articles.append(Article(title: event.title, link: event.link, startDate: stringToDate(event.startDate), endDate: stringToDate(event.endDate), startTime: event.startTime, endTime: event.endTime, calendar: nil, alert: nil))
            }
        }
        return articles
    }

    func removeOld(_ input: [Article]) -> [Article] {
        var articles = [Article]()
        let cutOff = Calendar.current.startOfDay(for: Date())
        for i in 0 ..< input.count {
            if input[i].endDate >= cutOff {
                articles.append(input[i])
            }
        }
        return articles
    }

    func mergeDuplicates(_ input: [Article]) -> [Article] {
        var articlesArray = input
        var allArray = [String]()
        var dupArray = [String]()

        for event in articlesArray {
            if allArray.contains(event.title) && dupArray.contains(event.title) == false {
                dupArray.append(event.title)
            } else {
                allArray.append(event.title)
            }
        }
        for match in dupArray {
            var tempMatches = articlesArray.filter { $0.title == match }
            tempMatches = tempMatches.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
            if daysBetweenDates(startDate: tempMatches[0].startDate, endDate: tempMatches[tempMatches.count - 1].startDate) + 1 == tempMatches.count {
                let startDate = tempMatches.first!.startDate
                let endDate = tempMatches.last!.startDate
                let tempLink = tempMatches.first!.link
                articlesArray = articlesArray.filter { $0.title != match }
                articlesArray.append(Article(title: match, link: tempLink, startDate: startDate, endDate: endDate, startTime: "none", endTime: "none", calendar: nil, alert: nil))
            }
        }
        articlesArray = articlesArray.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        return articlesArray
    }

    func processArticles(_ array: [Article]) -> [ArticleGroup] {
        var tempArray = [ArticleGroup]()
        let calendar = Calendar.current

        for thing in array {
            let year = calendar.component(.year, from: thing.startDate)
            let month = calendar.component(.month, from: thing.startDate)
            var exists = false
            for i in 0..<tempArray.count {
                if tempArray[i].year == year && tempArray[i].month == month {
                    tempArray[i].articles.append(thing)
                    exists = true
                }
            }
            if exists == false {
                tempArray.append(ArticleGroup(year: year, month: month, articles: [thing]))
            }
        }
        return tempArray
    }

    func loadArticles() -> [Article] {
        var titleArray: [String]!
        var linkArray: [String]!
        var startDateArray: [Date]!
        var endDateArray: [Date]!
        var startTimeArray: [String]!
        var endTimeArray: [String]!
        var temp = [Article]()
        titleArray = defaults.array(forKey: "titleArray") as! [String]
        linkArray = defaults.array(forKey: "linkArray") as! [String]
        startDateArray = defaults.array(forKey: "startDateArray") as! [Date]
        endDateArray = defaults.array(forKey: "endDateArray") as! [Date]
        startTimeArray = defaults.array(forKey: "startTimeArray") as! [String]
        endTimeArray = defaults.array(forKey: "endTimeArray") as! [String]
        for i in 0 ..< titleArray.count {
            temp.append(Article(title: titleArray[i], link: linkArray[i], startDate: startDateArray[i], endDate: endDateArray[i], startTime: startTimeArray[i], endTime: endTimeArray[i], calendar: nil, alert: nil))
        }
        return temp
    }

    func saveArticles(_ array: [Article]) {
        var titleArray = [String]()
        var linkArray = [String]()
        var startDateArray = [Date]()
        var endDateArray = [Date]()
        var startTimeArray = [String]()
        var endTimeArray = [String]()
        for i in 0 ..< array.count {
            titleArray.append(array[i].title)
            linkArray.append(array[i].link)
            startDateArray.append(array[i].startDate)
            endDateArray.append(array[i].endDate)
            startTimeArray.append(array[i].startTime)
            endTimeArray.append(array[i].endTime)
        }
        defaults.set(titleArray, forKey: "titleArray")
        defaults.set(linkArray, forKey: "linkArray")
        defaults.set(startDateArray, forKey: "startDateArray")
        defaults.set(endDateArray, forKey: "endDateArray")
        defaults.set(startTimeArray, forKey: "startTimeArray")
        defaults.set(endTimeArray, forKey: "endTimeArray")
    }
}

extension EventViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .left else { return nil }
        var actions = [SwipeAction]()
        let temp = self.articlesVisible[indexPath.section].articles[indexPath.row]
        if Date() < swipeFunctions.dateAndTime(date: temp.startDate, time: temp.startTime) {
            let calendarAction = SwipeAction(style: .default, title: "Calendar") { _, indexPath in self.articleToSave(indexPath) }
            calendarAction.image = UIImage(named: "CalendarLight")
            calendarAction.hidesWhenSelected = true
            if defaults.bool(forKey: "Is Dark") {
                calendarAction.backgroundColor = UIColor(rgba: "#CC6600")
            } else {
                calendarAction.backgroundColor = UIColor.orange
            }
            actions.append(calendarAction)
            let reminderAction = SwipeAction(style: .default, title: "Alert") { _, indexPath in self.articleToRemind(indexPath) }
            reminderAction.image = UIImage(named: "ReminderLight")
            reminderAction.hidesWhenSelected = true
            reminderAction.backgroundColor = appDelegate.themeBlue
            actions.append(reminderAction)
        }
        return actions
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.backgroundColor = .clear
        options.expansionStyle = .selection
        options.transitionStyle = .border
        return options
    }

    func articleToSave(_ indexPath: IndexPath) {
        let pscope = ThemePermissionScope()
        pscope.addPermission(EventsPermission(), message: "Lets us add events\r\nto your calendar.")
        pscope.show({ _, _ in
            let temp = self.articlesVisible[indexPath.section].articles[indexPath.row]
            if self.defaults.string(forKey: "Calendar Name") == nil {
                let cscope = CalendarScope()
                cscope.showAlert(finished: { done in
                    if done {
                        self.swipeFunctions.eventToggle(temp: temp)
                    }
                })
            } else {
                self.swipeFunctions.eventToggle(temp: temp)
            }
        }, cancelled: nil)
    }

    func articleToRemind(_ indexPath: IndexPath) {
        let pscope = ThemePermissionScope()
        pscope.addPermission(NotificationsPermission(), message: "Lets us send you\r\nan event notification.")
        pscope.show({ _, _ in
            let temp = self.articlesVisible[indexPath.section].articles[indexPath.row]
            self.swipeFunctions.reminderToggle(temp: temp)
        }, cancelled: nil)
    }
}
