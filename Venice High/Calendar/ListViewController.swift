//
//  ListViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 5/10/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import EventKit
import JGProgressHUD
import MarqueeLabel
import MWFeedParser
import PermissionScope
import SwipeCellKit

class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var loaded = false
    var firstRun = true
    var error = false
    var articleCount: Int!
    var articlesTemp = [Article]()
    var articlesSorted = [ArticleGroup]()
    var articlesVisible = [ArticleGroup]()
    var countTemp = [MWFeedItem]()
    var style: JGProgressHUDStyle!
    var hud: JGProgressHUD!
    var currentText: String = ""
    var searching: Bool = false
    var current: Date!
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var lastReturned = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        darkTheme()
        tableView.sectionIndexColor = appDelegate.themeBlue
        if defaults.bool(forKey: "Is Dark") {
            self.view.backgroundColor = .black
            style = .light
        } else {
            self.view.backgroundColor = .white
            style = .dark
        }
        hud = JGProgressHUD(style: style)
        self.navigationController?.navigationBar.tintColor = appDelegate.themeBlue
        tableView.backgroundColor = .clear
        tableView.sectionIndexBackgroundColor = .clear
        hud.textLabel.text = "Loading Events"
        hud.detailTextLabel.text = "0% Complete"
        hud.parallaxMode = .device
        hud.interactionType = .blockAllTouches
        hud.indicatorView = JGProgressHUDRingIndicatorView()
        hud.progress = 0.0
        hud.show(in: self.view)
        self.navigationItem.setRightBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Calendar"), style: .plain, target: self, action: #selector(openVisual)), animated: true)
    }

    func openVisual() {
        let test = defaults.array(forKey: "titleArray") ?? []
        if test.isEmpty == false {
            self.performSegue(withIdentifier: "showVisual", sender: nil)
        }
    }

    func darkTheme() {
        if defaults.bool(forKey: "Is Dark") {
            searchBar.backgroundColor = .black
            searchBar.backgroundImage = UIImage()
            searchBar.isTranslucent = true
            searchBar.keyboardAppearance = UIKeyboardAppearance.dark
            searchBar.textColor = .white
            for subView in searchBar.subviews {
                for subViewOne in subView.subviews {
                    if let textField = subViewOne as? UITextField {
                        subViewOne.backgroundColor = .darkGray
                        let textFieldInsideUISearchBarLabel = textField.value(forKey: "placeholderLabel") as? UILabel
                        textFieldInsideUISearchBarLabel?.textColor = .lightGray
                    }
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if loaded == false {
            initialLoad()
            loaded = true
        }
    }

    func initialLoad() {
        let test = defaults.array(forKey: "titleArray") ?? []
        if internet() {
            if test.isEmpty == false {
                articlesTemp = loadArticles()
                processArray()
                hud.dismiss(afterDelay: 0)
                tableView.reloadData()
                if dateChecker() {
                    loadCount()
                }
            } else {
                loadCount()
            }
        } else {
            hud.dismiss(afterDelay: 0)
            if test.isEmpty == false {
                articlesTemp = loadArticles()
                processArray()
                tableView.reloadData()
            } else {
                searchBar.isUserInteractionEnabled = false
                let alertController = UIAlertController(title: "No Network", message: "Please connect your phone to a wifi or cellular network.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func dateChecker() -> Bool {
        if let oldDate = defaults.object(forKey: "Last Refreshed") {
            let now = Date()
            let then = oldDate as! Date
            return (daysBetweenDates(startDate: then, endDate: now) > 0)
        }
        return true
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
                self.tableView.reloadData()
                self.defaults.set(Date(), forKey: "Last Refreshed")
            }
        }
    }
}

extension ListViewController: MWFeedParserDelegate {
    func request() {
        let URL = Foundation.URL(string: "https://venicehs-lausd-ca.schoolloop.com/cms/rss?d=x&group_id=1442645854073&types=_assignment__event_&return_url=1494562389332")
        let feedParser = MWFeedParser(feedURL: URL)!
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
        }
    }

    func feedParser(_ parser: MWFeedParser, didParseFeedItem item: MWFeedItem) {
        if firstRun {
            countTemp.append(item)
        } else {
            let (temp, start, end) = getDates(website: item.link)
            if temp == "error" {
                error = true
            }
            let dateString = temp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            let date = dateFormatter.date(from: dateString)!
            articlesTemp.append(Article(title: item.title, link: item.link, startDate: date, endDate: date, startTime: start, endTime: end))
            let numerator = Float(articlesTemp.count)
            let denominator = Float(articleCount)
            hud.progress = numerator/denominator
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {self.hud.detailTextLabel.text = "\(Int((numerator/denominator)*100))% Complete"})
        }
    }

    func getDates(website: String) -> (String, String, String) {
        var html: String!
        let myURLString = website
        let myURL = URL(string: myURLString)!
        do {
            html = try String(contentsOf: myURL, encoding: .ascii)
        } catch let error {
            print("Error: \(error)")
        }
        return (html.slice(from: "<div class=\"date\">", to: "</div>") ?? "error", html.slice(from: "<b>Start Time:</b> ", to: "</td>") ?? "none", html.slice(from: "<b>End Time:</b> ", to: "</td>") ?? "none")
    }
}

extension ListViewController /*Data Processing*/ {
    func processArray() {
        articlesTemp = articlesTemp.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        articlesTemp = removeOld(articlesTemp)
        articlesTemp = mergeDuplicates(articlesTemp)
        articlesSorted = processArticles(articlesTemp)
        articlesVisible = articlesSorted
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
            if daysBetweenDates(startDate: tempMatches[0].startDate, endDate: tempMatches[tempMatches.count-1].startDate)+1 == tempMatches.count {
                let startDate = tempMatches.first!.startDate
                let endDate = tempMatches.last!.startDate
                let tempLink = tempMatches.first!.link
                articlesArray = articlesArray.filter { $0.title != match }
                articlesArray.append(Article(title: match, link: tempLink, startDate: startDate, endDate: endDate, startTime: "none", endTime: "none"))
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
            temp.append(Article(title: titleArray[i], link: linkArray[i], startDate: startDateArray[i], endDate: endDateArray[i], startTime: startTimeArray[i], endTime: endTimeArray[i]))
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
        for i in 0..<array.count {
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

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return months[articlesVisible[section].month-1]
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var temp = [String]()
        articlesVisible = articlesVisible.sorted(by: { $0.month < $1.month })
        articlesVisible = articlesVisible.sorted(by: { $0.year < $1.year })
        for i in articlesVisible {
            temp.append(months[i.month-1].getFirst(3))
            temp.append(" ")
            if articlesVisible.count < 12 {
                temp.append(" ")
            }
        }
        if articlesVisible.count > 0 {
            temp.remove(at: temp.count-1)
            if articlesVisible.count < 12 {
                temp.remove(at: temp.count-1)
            }
        }
        return temp
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if title != " " {
            lastReturned = index/3
            return index/3
        } else {
            return lastReturned
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if defaults.bool(forKey: "Is Dark") {
            view.tintColor = .lightGray
        } else {
            view.tintColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
        }
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .black
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return articlesVisible.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesVisible[section].articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = articlesVisible[indexPath.section].articles[indexPath.row]
        if (article.startTime == "none" && article.endTime == "none")
        || (article.startTime == "12:00 AM" && article.endTime == "11:55 PM")
        || (article.startTime == "12:00 AM" && article.endTime == "11:59 PM") {
            let aCell = tableView.dequeueReusableCell(withIdentifier: "notime", for: indexPath) as! NoTimeTableViewCell
            aCell.backgroundColor = .clear
            aCell.titleLabel.tapToScroll = true
            aCell.titleLabel.rate = 75.0
            aCell.titleLabel.trailingBuffer = 50.0
            aCell.titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: aCell.titleLabel.font.pointSize)
            if defaults.bool(forKey: "Is Dark") {
                aCell.titleLabel.textColor = .white
            } else {
                aCell.titleLabel.textColor = .black
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            if article.startDate == article.endDate {
                let dateString = formatter.string(from: article.startDate)
                aCell.titleLabel.text = dateString.dropLast(3) + ": " + article.title
            } else {
                let startString = formatter.string(from: article.startDate)
                let endString = formatter.string(from: article.endDate)
                aCell.titleLabel.text = startString.dropLast(3) + "-" + endString.dropLast(3) + ": " + article.title
            }
            aCell.delegate = self
            return aCell
        } else {
            let aCell = tableView.dequeueReusableCell(withIdentifier: "time", for: indexPath) as! TimeTableViewCell
            aCell.backgroundColor = .clear
            aCell.titleLabel.tapToScroll = true
            aCell.titleLabel.rate = 75.0
            aCell.titleLabel.trailingBuffer = 50.0
            aCell.titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: aCell.titleLabel.font.pointSize)
            if defaults.bool(forKey: "Is Dark") {
                aCell.titleLabel.textColor = .white
                aCell.timeLabel.textColor = .white
            } else {
                aCell.titleLabel.textColor = .black
                aCell.timeLabel.textColor = .black
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            let dateString = formatter.string(from: article.startDate)
            aCell.titleLabel.text = dateString.dropLast(3) + ": " + article.title
            aCell.delegate = self
            aCell.timeLabel.text = article.startTime + " to " + article.endTime
            return aCell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let temp = self.tableView.frame.height/62.5
        return self.tableView.frame.height/round(temp)
    }
}

extension ListViewController: UISearchBarDelegate {
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
        searchBar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentText = searchText
        refreshData()
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

extension ListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .left else { return nil }

        let calendarAction = SwipeAction(style: .default, title: nil) { _, indexPath in
            self.articleToSave(indexPath)
        }
        calendarAction.image = UIImage(named: "CalendarLight")
        calendarAction.backgroundColor = .orange
        calendarAction.hidesWhenSelected = true
        return [calendarAction]
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .drag
        return options
    }

    func articleToSave(_ indexPath: IndexPath) {
        let pscope = PermissionScope()
        pscope.addPermission(EventsPermission(), message: "Lets us add events\r\nto your calendar.")
        pscope.show({ _, _ in
            let temp = self.articlesVisible[indexPath.section].articles[indexPath.row]
            if self.defaults.string(forKey: "Calendar Name") == "" {
                let cscope = CalendarScope()
                cscope.showAlert(finished: {done in
                    if done {
                        self.saveToCalendarOne(temp: temp)
                    }
                })
            } else {
                self.saveToCalendarOne(temp: temp)
            }
        }, cancelled: nil)
    }
}

extension ListViewController /*Calendar Saving Functions*/ {
    func saveToCalendarOne(temp: Article, force: Bool = false) {
        saveToCalendarTwo(temp, force, completion: {status, error in
            if status == false {
                if error!.domain == "SavingEvent" && error!.code == 1 {
                    let alertController = UIAlertController(title: nil, message: "This event is already in your calendar.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Add Anyway", style: UIAlertActionStyle.default, handler: {_ in
                        self.saveToCalendarOne(temp: temp, force: true)
                    }))
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                } else if error!.code == 14 {
                    let alertController = UIAlertController(title: "\(self.defaults.string(forKey: "Calendar Name")!) Calendar Not Found", message: "Please select new event calendar.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
                        let cscope = CalendarScope()
                        cscope.showAlert(finished: {_ in
                            self.saveToCalendarOne(temp: temp)
                        })
                    }))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: error!.domain, message: error!.description.slice(from: "\"", to: "\"")!, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                if self.defaults.bool(forKey: "Event Alert") {
                    let alertController = UIAlertController(title: nil, message: "Event successfully saved to your calendar.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Don't Show Again", style: UIAlertActionStyle.cancel, handler: { _ in
                        self.defaults.set(false, forKey: "Event Alert")
                    }))
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    DispatchQueue.main.async {
                        let popup = JGProgressHUD(style: self.style)
                        popup.indicatorView = JGProgressHUDSuccessIndicatorView()
                        popup.textLabel.text = "Success"
                        popup.parallaxMode = .device
                        popup.interactionType = .blockTouchesOnHUDView
                        popup.show(in: self.parent!.view)
                        popup.dismiss(afterDelay: 1.0)
                    }
                }
            }
        })
    }

    func saveToCalendarTwo(_ temp: Article, _ force: Bool, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)

        event.title = temp.title
        event.url = URL(string: temp.link)

        if (temp.startTime == "none" && temp.endTime == "none") || (temp.startTime == "12:00 AM" && temp.endTime == "11:59 PM") || (temp.startTime == "12:00 AM" && temp.endTime == "11:55 PM") {
            event.isAllDay = true
            event.startDate = temp.startDate
            event.endDate = temp.endDate
        } else {
            event.isAllDay = false
            event.startDate = dateAndTime(date: temp.startDate, time: temp.startTime)
            event.endDate = dateAndTime(date: temp.endDate, time: temp.endTime)
        }

        if force == false {
            let possibleDuplicates = eventStore.events(matching: eventStore.predicateForEvents(withStart: event.startDate, end: event.endDate, calendars: nil))
            for i in possibleDuplicates {
                if i.title == temp.title {
                    completion?(false, NSError(domain: "SavingEvent", code: 1, userInfo: nil))
                    return
                }
            }
        }

        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted && error == nil {
                var selectedCalendar = EKCalendar(for: .event, eventStore: eventStore)
                let selectedCalendarIdentifier = UserDefaults.standard.string(forKey: "Calendar Identifier")!
                let allCalendars = eventStore.calendars(for: .event)
                for calendar: EKCalendar in allCalendars {
                    if (calendar.calendarIdentifier == selectedCalendarIdentifier) {
                        selectedCalendar = calendar
                    }
                }
                event.calendar = selectedCalendar
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        }
    }

    func dateAndTime(date: Date, time: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        var dateString = formatter.string(from: date)
        dateString = dateString + " " + time
        formatter.dateFormat = "MM/dd/yy h:mm a"
        return formatter.date(from: dateString)!
    }
}
