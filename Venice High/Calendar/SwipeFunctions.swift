//
//  SwipeFunctions.swift
//  Venice High
//
//  Created by Steven Steiner on 2/9/18.
//  Copyright © 2018 Steven Steiner. All rights reserved.
//

import EventKit
import JGProgressHUD
import PMAlertController
import SwipeCellKit
import UIKit

class SwipeFunctions {
    let defaults = UserDefaults.standard
    var parentController: UIViewController!
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    init(_ parentController: UIViewController) {
        self.parentController = parentController
    }
}

extension SwipeFunctions /*Calendar Saving Functions*/ {
    func calendarCheck(temp: Article) -> Bool {
        if ThemePermissionScope().statusEvents() == .authorized {
            var startDate: Date!
            var endDate: Date!
            let eventStore = EKEventStore()
            if (temp.startTime == "none" && temp.endTime == "none") || (temp.startTime == "12:00 AM" && temp.endTime == "11:59 PM") || (temp.startTime == "12:00 AM" && temp.endTime == "11:55 PM") {
                startDate = temp.startDate.yesterday
                endDate = temp.endDate.tomorrow
            } else {
                startDate = dateAndTime(date: temp.startDate, time: temp.startTime)
                endDate = dateAndTime(date: temp.endDate, time: temp.endTime)
            }

            let possibleDuplicates = eventStore.events(matching: eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil))
            for i in possibleDuplicates {
                if i.title == temp.title {
                    return true
                }
            }
        }
        return false
    }

    func eventToggle(temp: Article) {
        if calendarCheck(temp: temp) {
            let alertController = PMAlertController(title: "Duplicate Event", message: "This event is already in your calendar.", preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
            alertController.addAction(PMAlertAction(title: "Delete", style: PMAlertActionStyle.destructive, handler: {
                self.removeEvent(temp: temp)
            }))
            alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.cancel, handler: nil))
            parentController.present(alertController, animated: true, completion: nil)
        } else {
            saveEvent(temp: temp)
        }
    }

    func removeEvent(temp: Article) {
        var startDate: Date!
        var endDate: Date!
        var event: EKEvent?
        let eventStore = EKEventStore()
        var popup: JGProgressHUD!
        if defaults.bool(forKey: "Is Dark") {
            popup = JGProgressHUD(style: .light)
        } else {
            popup = JGProgressHUD(style: .dark)
        }
        popup.indicatorView = JGProgressHUDSuccessIndicatorView()
        popup.parallaxMode = .device
        popup.interactionType = .blockTouchesOnHUDView
        if (temp.startTime == "none" && temp.endTime == "none") || (temp.startTime == "12:00 AM" && temp.endTime == "11:59 PM") || (temp.startTime == "12:00 AM" && temp.endTime == "11:55 PM") {
            startDate = temp.startDate.yesterday
            endDate = temp.endDate.tomorrow
        } else {
            startDate = dateAndTime(date: temp.startDate, time: temp.startTime)
            endDate = dateAndTime(date: temp.endDate, time: temp.endTime)
        }

        let possibleDuplicates = eventStore.events(matching: eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil))
        for i in possibleDuplicates {
            if i.title == temp.title {
                event = i
            }
        }
        if event != nil {
            do {
                try eventStore.remove(event!, span: .thisEvent)
            } catch {
                print(error)
                popup.textLabel.text = "Error Removing"
                popup.show(in: self.appDelegate.window!.rootViewController!.view)
                popup.dismiss(afterDelay: 1.0)
                return
            }
            popup.textLabel.text = "Removed Event"
            popup.show(in: self.appDelegate.window!.rootViewController!.view)
            popup.dismiss(afterDelay: 1.0)
        } else {
            popup.textLabel.text = "Error Removing"
            popup.show(in: self.appDelegate.window!.rootViewController!.view)
            popup.dismiss(afterDelay: 1.0)
        }
    }

    func saveEvent(temp: Article, force: Bool = false) {
        saveToCalendar(temp, force, completion: { status, error in
            if status == false {
                if error!.domain == "SavingEvent" && error!.code == 1 {
                    let alertController = PMAlertController(title: "Duplicate Event", message: "This event is already in your calendar.", preferredStyle: .alert, preferredTheme: self.appDelegate.themeAlert)
                    alertController.addAction(PMAlertAction(title: "Add Anyway", style: PMAlertActionStyle.default, handler: {
                        self.saveEvent(temp: temp, force: true)
                    }))
                    alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.cancel, handler: nil))
                    self.parentController.present(alertController, animated: true, completion: nil)
                } else if error!.domain == "SavingEvent" && error!.code == 2 {
                    let alertController = PMAlertController(title: "\"\(self.defaults.string(forKey: "Calendar Name")!)\" Calendar Not Found", message: "Please select a new calendar.", preferredStyle: .alert, preferredTheme: self.appDelegate.themeAlert)
                    alertController.addAction(PMAlertAction(title: "Cancel", style: PMAlertActionStyle.cancel, handler: nil))
                    alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.default, handler: {
                        let cscope = CalendarScope()
                        cscope.showAlert(finished: { _ in
                            self.saveEvent(temp: temp)
                        })
                    }))
                    self.parentController.present(alertController, animated: true, completion: nil)
                } else if error!.domain == "EKErrorDomain" && error!.code == 6 {
                    let alertController = PMAlertController(title: "\"\(self.defaults.string(forKey: "Calendar Name")!)\" Is Read Only", message: "Please select a different calendar.", preferredStyle: .alert, preferredTheme: self.appDelegate.themeAlert)
                    alertController.addAction(PMAlertAction(title: "Cancel", style: PMAlertActionStyle.cancel, handler: nil))
                    alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.default, handler: {
                        let cscope = CalendarScope()
                        cscope.showAlert(finished: { _ in
                            self.saveEvent(temp: temp)
                        })
                    }))
                    self.parentController.present(alertController, animated: true, completion: nil)
                } else {
                    print(error!.domain)
                    print(error!.code)
                    print(error!.description)
                    let alertController = PMAlertController(title: error!.domain, message: error!.description.slice(from: "\"", to: "\"")!, preferredStyle: .alert, preferredTheme: self.appDelegate.themeAlert)
                    alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.default, handler: nil))
                    self.parentController.present(alertController, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    var popup: JGProgressHUD!
                    if self.defaults.bool(forKey: "Is Dark") {
                        popup = JGProgressHUD(style: .light)
                    } else {
                        popup = JGProgressHUD(style: .dark)
                    }
                    popup.indicatorView = JGProgressHUDSuccessIndicatorView()
                    popup.textLabel.text = "Added Event"
                    popup.parallaxMode = .device
                    popup.interactionType = .blockTouchesOnHUDView
                    popup.show(in: self.appDelegate.window!.rootViewController!.view)
                    popup.dismiss(afterDelay: 1.0)
                }
            }
        })
    }

    func saveToCalendar(_ temp: Article, _ force: Bool, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)

        event.title = temp.title
        if temp.link != "" {
            event.url = URL(string: temp.link)
        }
        event.notes = "Added by the Venice High App"

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
                let selectedCalendarIdentifier = UserDefaults.standard.string(forKey: "Calendar Identifier")
                let allCalendars = eventStore.calendars(for: .event)
                var calendarMatch = false
                for calendar: EKCalendar in allCalendars {
                    if (calendar.calendarIdentifier == selectedCalendarIdentifier) {
                        selectedCalendar = calendar
                        calendarMatch = true
                    }
                }
                if calendarMatch == false {
                    completion?(false, NSError(domain: "SavingEvent", code: 2, userInfo: nil))
                    return
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
        if time == "none" || time == "12:00 AM" {
            return date
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yy"
        let dateString = formatter.string(from: date) + " " + time
        formatter.dateFormat = "MM/dd/yy h:mm a"
        return formatter.date(from: dateString)!
    }
}

extension SwipeFunctions /*Event Alert Functions*/ {
    func reminderCheck(temp: Article) -> Bool {
        if ThemePermissionScope().statusNotifications() == .authorized {
            let phrase = temp.title + String(describing: temp.startDate)
            let uuid = String(describing: phrase.utf8.md5)
            if let notifications = UIApplication.shared.scheduledLocalNotifications {
                for notification in notifications {
                    if notification.userInfo!["UUID"] as! String == uuid {
                        return true
                    }
                }
            }
        }
        return false
    }

    func reminderToggle(temp: Article) {
        if reminderCheck(temp: temp) {
            let alertController = PMAlertController(title: "Duplicate Alert", message: "An alert already exists for this event.", preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
            alertController.addAction(PMAlertAction(title: "Delete", style: PMAlertActionStyle.destructive, handler: {
                self.deleteReminder(temp: temp)
            }))
            alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.cancel, handler: nil))
            parentController.present(alertController, animated: true, completion: nil)
        } else {
            saveReminder(temp: temp)
        }
    }

    func saveReminder(temp: Article) {
        let notification = UILocalNotification()
        notification.alertTitle = "Today at Venice"
        if Date() > dateAndTime(date: temp.startDate, time: temp.startTime) {
            return
        }
        if (temp.startTime == "none" && temp.endTime == "none") || (temp.startTime == "12:00 AM" && temp.endTime == "11:59 PM") || (temp.startTime == "12:00 AM" && temp.endTime == "11:55 PM") {
            notification.alertBody = "\(temp.title)"
            notification.fireDate = setDate(date: temp.startDate, hour: 7, minute: 0)
        } else {
            notification.alertBody = "\(temp.title) from \(temp.startTime.lowercased()) to \(temp.endTime.lowercased())"
            notification.fireDate = dateAndTime(date: temp.startDate, time: temp.startTime)
        }

        let phrase = temp.title + String(describing: temp.startDate)
        notification.userInfo = ["UUID": String(describing: phrase.utf8.md5)]
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
        var popup: JGProgressHUD!
        if self.defaults.bool(forKey: "Is Dark") {
            popup = JGProgressHUD(style: .light)
        } else {
            popup = JGProgressHUD(style: .dark)
        }
        popup.indicatorView = JGProgressHUDSuccessIndicatorView()
        popup.textLabel.text = "Added Alert"
        popup.parallaxMode = .device
        popup.interactionType = .blockTouchesOnHUDView
        popup.show(in: self.appDelegate.window!.rootViewController!.view)
        popup.dismiss(afterDelay: 1.0)
    }

    func deleteReminder(temp: Article) {
        let phrase = temp.title + String(describing: temp.startDate)
        let uuid = String(describing: phrase.utf8.md5)
        if let notifications = UIApplication.shared.scheduledLocalNotifications {
            for notification in notifications {
                if notification.userInfo!["UUID"] as! String == uuid {
                    UIApplication.shared.cancelLocalNotification(notification)
                    var popup: JGProgressHUD!
                    if self.defaults.bool(forKey: "Is Dark") {
                        popup = JGProgressHUD(style: .light)
                    } else {
                        popup = JGProgressHUD(style: .dark)
                    }
                    popup.indicatorView = JGProgressHUDSuccessIndicatorView()
                    popup.textLabel.text = "Removed Alert"
                    popup.parallaxMode = .device
                    popup.interactionType = .blockTouchesOnHUDView
                    popup.show(in: self.appDelegate.window!.rootViewController!.view)
                    popup.dismiss(afterDelay: 1.0)
                }
            }
        }
    }

    func setDate(date: Date, hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components)!
    }
}
