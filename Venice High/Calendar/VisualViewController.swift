//
//  VisualViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 1/5/18.
//  Copyright © 2018 steets250. All rights reserved.
//

import Cartography
import EventKit
import FSCalendar
import JGProgressHUD
import PermissionScope
import SwipeCellKit
import SwiftWebVC

class VisualViewController: UIViewController {
    var container: UIView!
    var calendarView: FSCalendar!
    var seperatorView: UIView!
    var tableView: UITableView!

    var dayEvents = [Article]()
    var eventList = [Article]()
    var selectedDate = Date()
    var style: JGProgressHUDStyle!
    var extras = [Event]()
    var swipeFunctions: SwipeFunctions!

    override func viewDidLoad() {
        super.viewDidLoad()

        Setup.page(self, title: "Calendar View", leftButton: nil, rightButton: UIBarButtonItem(image: UIImage(named: "Help"), style: .plain, target: self, action: #selector(openHelp)), largeTitle: false, back: false)

        extras = appDelegate.eventData
        eventList = loadArticles()
        eventList = importManual(eventList)
        swipeFunctions = SwipeFunctions(self)

        pageSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visualSetup()
    }

    func pageSetup() {
        container = UIView()
        container.backgroundColor = .clear
        view.addSubview(container)
        constrain(container, view, car_topLayoutGuide, car_bottomLayoutGuide) { container, view, car_topLayoutGuide, car_bottomLayoutGuide in
            container.left == view.left
            container.right == view.right
            container.top == car_topLayoutGuide.bottom
            container.bottom == car_bottomLayoutGuide.top
        }

        calendarView = FSCalendar()
        calendarView.dataSource = self
        calendarView.delegate = self
        container.addSubview(calendarView)

        seperatorView = UIView()
        seperatorView.backgroundColor = .black
        container.addSubview(seperatorView)

        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: "eventCell")
        container.addSubview(tableView)

        constrain(calendarView, seperatorView, tableView, container) { calendarView, seperatorView, tableView, container in
            calendarView.left == container.left
            calendarView.right == container.right
            calendarView.top == container.top
            calendarView.width == calendarView.height

            seperatorView.left == container.left
            seperatorView.right == container.right
            seperatorView.top == calendarView.bottom
            seperatorView.height == 1

            tableView.left == container.left
            tableView.right == container.right
            tableView.top == seperatorView.bottom
            tableView.bottom == container.bottom
        }
    }

    func visualSetup() {
        if defaults.bool(forKey: "Is Dark") {
            style = .light
            calendarView.backgroundColor = .black
            calendarView.appearance.todayColor = UIColor.red.withAlphaComponent(0.5)
            calendarView.appearance.selectionColor = UIColor.blue.withAlphaComponent(0.5)
            calendarView.appearance.headerTitleColor = .white
            calendarView.appearance.selectionColor = .blue
            calendarView.appearance.titleTodayColor = .white
            calendarView.appearance.titleDefaultColor = .white
            calendarView.appearance.titleSelectionColor = .white
            calendarView.appearance.titlePlaceholderColor = .lightGray
            calendarView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            tableView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            self.view.backgroundColor = .black
        } else {
            style = .dark
            calendarView.backgroundColor = .white
            calendarView.appearance.todayColor = .red
            calendarView.appearance.selectionColor = .blue
            self.view.backgroundColor = .white
        }
        calendarView.appearance.headerTitleColor = appDelegate.themeBlue
        calendarView.appearance.weekdayTextColor = appDelegate.themeBlue
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

    func importManual(_ input: [Article]) -> [Article] {
        var articles = input
        if extras.isEmpty == false {
            for event in extras {
                articles.append(Article(title: event.title, link: event.link, startDate: stringToDate(event.startDate), endDate: stringToDate(event.endDate), startTime: event.startTime, endTime: event.endTime, calendar: nil, alert: nil))
            }
        }
        return articles
    }

    func stringToDate(_ input: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.date(from: input)!
    }

    @objc func openHelp() {
        AlertScope.showAlert(.visualViewController, self)
    }
}

extension VisualViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var dots = 0
        for event in eventList {
            if date.isBetween(date: event.startDate, andDate: event.endDate) {
                dots += 1
            }
        }
        return dots
    }

    func minimumDate(for calendar: FSCalendar) -> Date {
        if appDelegate.schoolStart < eventList[0].startDate {
            return appDelegate.schoolStart
        } else {
            return eventList[0].startDate
        }
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        if appDelegate.schoolEnd > eventList[eventList.count - 1].endDate {
            return appDelegate.schoolEnd
        } else {
            return eventList[eventList.count - 1].endDate
        }
    }
}

extension VisualViewController: FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateChange(date: date)
    }

    func dateChange(date: Date) {
        dayEvents.removeAll()
        for event in eventList {
            if date.isBetween(date: event.startDate, andDate: event.endDate) {
                dayEvents.append(event)
            }
        }
        dayEvents = dayEvents.sorted(by: { $0.title.compare($1.title) == .orderedAscending })
        dayEvents = dayEvents.sorted(by: { swipeFunctions.dateAndTime(date: $0.startDate, time: $0.startTime).compare(swipeFunctions.dateAndTime(date: $1.startDate, time: $1.startTime)) == .orderedAscending })
        tableView.reloadData()
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let calendar = Calendar.current
        if date.weekday > 1 && date.weekday < 7 && calendar.isDateInToday(date) == false {
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)

            for date in appDelegate.dateData {
                if (year == date.year && month == date.month && day == date.day) {
                    if date.schedule == 2 {
                        if defaults.bool(forKey: "Is Dark") {
                            return UIColor.green.withAlphaComponent(0.5)
                        } else {
                            return UIColor.green
                        }
                    }
                    if date.schedule == 3 {
                        if defaults.bool(forKey: "Is Dark") {
                            return UIColor.yellow.withAlphaComponent(0.5)
                        } else {
                            return UIColor.yellow
                        }
                    }
                    if date.schedule == 4 {
                        if defaults.bool(forKey: "Is Dark") {
                            return UIColor.orange.withAlphaComponent(0.5)
                        } else {
                            return UIColor.orange
                        }
                    }
                    if date.schedule == 5 {
                        if defaults.bool(forKey: "Is Dark") {
                            return UIColor.purple.withAlphaComponent(0.5)
                        } else {
                            return UIColor.purple
                        }
                    }
                    if date.schedule == 0 {
                        if defaults.bool(forKey: "Is Dark") {
                            return UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 0.5)
                        } else {
                            return UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
                        }
                    }
                }
            }
        }
        return nil
    }
}

extension VisualViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if calendarView.selectedDate == nil {
            emptyMessage(message: "Select a date on the calendar.", viewController: self)
            return 0
        } else if dayEvents.isEmpty {
            let currentDay = calendarView.selectedDate ?? Date()
            let calendar = Calendar.current
            let year = String(calendar.component(.year, from: currentDay))
            let month = String(calendar.component(.month, from: currentDay))
            let day = String(calendar.component(.day, from: currentDay))
            emptyMessage(message: "No events found on \(month)/\(day)/\(year.getLast(2)).", viewController: self)
            return 0
        } else {
            tableView.backgroundView = .none
            tableView.separatorStyle = .singleLine
            return dayEvents.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if calendarView.selectedDate == nil || dayEvents.isEmpty {
            let aCell = UITableViewCell()
            aCell.selectionStyle = .none
            aCell.backgroundColor = .clear
            return aCell
        } else {
            let article = dayEvents[indexPath.row]
            let aCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
            aCell.selectionStyle = .none
            aCell.backgroundColor = .clear
            aCell.delegate = self
            aCell.titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 18.0)
            if article.link == "" {
                aCell.selectionStyle = .none
            }
            if defaults.bool(forKey: "Is Dark") {
                aCell.titleLabel.textColor = .white
            } else {
                aCell.titleLabel.textColor = .black
            }
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
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77
    }

    func emptyMessage(message: String, viewController: VisualViewController) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        messageLabel.text = message
        if defaults.bool(forKey: "Is Dark") {
            messageLabel.textColor = .white
        } else {
            messageLabel.textColor = .black
        }
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "System", size: 20)
        messageLabel.sizeToFit()
        viewController.tableView.backgroundView = messageLabel
        viewController.tableView.separatorStyle = .none
    }
}

extension VisualViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = dayEvents[indexPath.row]
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
}

extension VisualViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .left else { return nil }
        var actions = [SwipeAction]()
        let temp = self.dayEvents[indexPath.row]
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
            let temp = self.dayEvents[indexPath.row]
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
            let temp = self.dayEvents[indexPath.row]
            self.swipeFunctions.reminderToggle(temp: temp)
        }, cancelled: nil)
    }
}
