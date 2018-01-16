//
//  VisualViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 1/5/18.
//  Copyright © 2018 steets250. All rights reserved.
//

import EventKit
import FSCalendar
import JGProgressHUD
import PermissionScope
import SwipeCellKit

class VisualViewController: UIViewController {
    @IBOutlet var calendarView: FSCalendar!
    @IBOutlet var seperatorView: UIView!
    @IBOutlet var tableView: UITableView!

    var dayEvents = [Article]()
    var eventList = [Article]()
    var selectedDate = Date()
    var style: JGProgressHUDStyle!

    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.bool(forKey: "Is Dark") {
            style = .light
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
        } else {
            style = .dark
            calendarView.appearance.todayColor = .red
            calendarView.appearance.selectionColor = .blue
        }
        calendarView.appearance.headerTitleColor = appDelegate.themeBlue
        calendarView.appearance.weekdayTextColor = appDelegate.themeBlue

        eventList = loadArticles()
        calendarView.select(Date())
        dateChange(date: calendarView.selectedDate!)

        let rightBarItem = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(openToday))
        self.navigationItem.rightBarButtonItem = rightBarItem
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

    func openToday() {
        calendarView.select(Date())
        dateChange(date: calendarView.selectedDate!)
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
        if appDelegate.schoolEnd > eventList[eventList.count-1].endDate {
            return appDelegate.schoolEnd
        } else {
            return eventList[eventList.count-1].endDate
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
                            return UIColor.purple.withAlphaComponent(0.5)
                        } else {
                            return UIColor.purple
                        }
                    }
                    if date.schedule == 5 {
                        if defaults.bool(forKey: "Is Dark") {
                            return UIColor.orange.withAlphaComponent(0.5)
                        } else {
                            return UIColor.orange
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
        if dayEvents.isEmpty {
            let currentDay = calendarView.selectedDate ?? Date()
            let calendar = Calendar.current
            let year = String(calendar.component(.year, from: currentDay))
            let month = String(calendar.component(.month, from: currentDay))
            let day = String(calendar.component(.day, from: currentDay))
            EmptyMessage(message: "No events found on \(month)/\(day)/\(year.getLast(2)).", viewController: self)
            return 0
        } else {
            tableView.backgroundView = .none
            tableView.separatorStyle = .singleLine
            return dayEvents.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dayEvents.isEmpty {
            let aCell = UITableViewCell()
            aCell.backgroundColor = .clear
            return aCell
        } else {
            let aCell = tableView.dequeueReusableCell(withIdentifier: "visualCell") as! VisualViewCell
            aCell.delegate = self
            aCell.backgroundColor = .clear
            if defaults.bool(forKey: "Is Dark") {
                aCell.titleLabel.textColor = .white
            }
            aCell.titleLabel.tapToScroll = true
            aCell.titleLabel.rate = 75.0
            aCell.titleLabel.trailingBuffer = 50.0
            aCell.titleLabel.text = dayEvents[indexPath.row].title
            return aCell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let temp = self.tableView.frame.height/62.5
        return self.tableView.frame.height/round(temp)
    }

    func EmptyMessage(message: String, viewController: VisualViewController) {
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

}

extension VisualViewController: SwipeTableViewCellDelegate {
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
            let temp = self.dayEvents[indexPath.row]
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

extension VisualViewController /*Calendar Saving Functions*/ {
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
