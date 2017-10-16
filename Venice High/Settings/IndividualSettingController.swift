//
//  IndividualStaffController.swift
//  Venice High
//
//  Created by Steven Steiner on 3/11/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import MessageUI
import SwiftWebVC
import UserNotifications

class IndividualSettingController: UIViewController {
    @IBOutlet weak var periodStartLabel: UILabel!
    @IBOutlet weak var periodStartSwitch: UISwitch!
    @IBOutlet weak var periodStartMinutes: UILabel!
    @IBOutlet weak var periodStartStepper: UIStepper!
    @IBOutlet weak var periodEndLabel: UILabel!
    @IBOutlet weak var periodEndSwitch: UISwitch!
    @IBOutlet weak var periodEndMinutes: UILabel!
    @IBOutlet weak var periodEndStepper: UIStepper!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var seperator: UIView!
    @IBOutlet var saveButton: UIButton!

    var periodStringViaSegue: String!
    var periodViaSegue: Int!

    var saveEnabled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.periodStringViaSegue
        darkTheme()

        periodStartSwitch.isOn = defaults.bool(forKey: "\(periodStringViaSegue) Start")
        periodStartStepper.tintColor = appDelegate.themeBlue
        periodStartStepper.minimumValue = 0
        if self.periodStringViaSegue == "Period 1" && defaults.bool(forKey: "Show Period 0") == false {
            periodStartStepper.maximumValue = 57
        } else {
            periodStartStepper.maximumValue = 7
        }
        periodStartStepper.value = defaults.double(forKey: "\(periodStringViaSegue) Start Minutes")
        periodStartMinutes.text = String(Int(periodStartStepper.value)) + " Minutes Before Start"
        periodEndSwitch.isOn = defaults.bool(forKey: "\(periodStringViaSegue) End")
        periodEndStepper.tintColor = appDelegate.themeBlue
        periodEndStepper.minimumValue = 0
        periodEndStepper.maximumValue = 10
        periodEndStepper.value = defaults.double(forKey: "\(periodStringViaSegue) End Minutes")
        periodEndMinutes.text = String(Int(periodEndStepper.value)) + " Minutes Before End"
        stepperAbility(periodStartSwitch, periodStartStepper, periodStartMinutes)
        stepperAbility(periodEndSwitch, periodEndStepper, periodEndMinutes)
        saveButton.setTitleColor(appDelegate.themeBlue, for: .normal)
        saveButton.layer.cornerRadius = 5
        saveButton.isEnabled = saveEnabled
        saveButton.backgroundColor = .clear
        saveButton.setTitleColor(.clear, for: .disabled)
    }

    func buttonColor() {
        if defaults.bool(forKey: "Is Dark") {
            saveButton.backgroundColor = .black
        } else {
            saveButton.backgroundColor = .white
        }
    }

    func darkTheme() {
        if defaults.bool(forKey: "Is Dark") {
            seperator.backgroundColor = .white
            periodStartSwitch.onTintColor = .lightGray
            periodStartSwitch.tintColor = .darkGray
            periodEndSwitch.onTintColor = .lightGray
            periodEndSwitch.tintColor = .darkGray
            periodStartLabel.textColor = .white
            periodEndLabel.textColor = .white
            periodStartMinutes.textColor = .white
            periodEndMinutes.textColor = .white
            backgroundView.layerGradient(colors: [UIColor(hex: "444444").cgColor, UIColor(hex: "111111").cgColor, UIColor(hex: "444444").cgColor])
        } else {
            seperator.backgroundColor = .black
            periodStartSwitch.onTintColor = .darkGray
            periodStartSwitch.tintColor = .lightGray
            periodEndSwitch.onTintColor = .darkGray
            periodEndSwitch.tintColor = .lightGray
            periodStartLabel.textColor = .black
            periodEndLabel.textColor = .black
            periodStartMinutes.textColor = .black
            periodEndMinutes.textColor = .black
            backgroundView.layerGradient(colors: [UIColor(hex: "BBBBBB").cgColor, UIColor(hex: "EEEEEE").cgColor, UIColor(hex: "BBBBBB").cgColor])
        }
    }

    @IBAction func periodStartSwitched(_ sender: UISwitch) {
        stepperAbility(sender, periodStartStepper, periodStartMinutes)
        saveEnabled = true
        saveButton.isEnabled = saveEnabled
        buttonColor()
    }

    @IBAction func periodEndSwitched(_ sender: UISwitch) {
        stepperAbility(sender, periodEndStepper, periodEndMinutes)
        saveEnabled = true
        saveButton.isEnabled = saveEnabled
        buttonColor()
    }

    func stepperAbility(_ sender: UISwitch, _ receiver: UIStepper, _ text: UILabel) {
        if sender.isOn {
            receiver.isEnabled = true
            UIView.animate(withDuration: 0.5, animations: {
                text.alpha = 1.0
                receiver.alpha = 1.0
            })
        } else {
            receiver.isEnabled = false
            UIView.animate(withDuration: 0.5, animations: {
                text.alpha = 0.25
                receiver.alpha = 0.25
            })
        }
    }

    @IBAction func periodStartStepped(_ sender: UIStepper) {
        periodStartMinutes.fadeTransition(0.2)
        if Int(periodStartStepper.value) == 1 {
            periodStartMinutes.text = String(Int(periodStartStepper.value)) + " Minute Before Start"
        } else {
            periodStartMinutes.text = String(Int(periodStartStepper.value)) + " Minutes Before Start"
        }
        saveEnabled = true
        saveButton.isEnabled = saveEnabled
        buttonColor()
    }

    @IBAction func periodEndStepped(_ sender: UIStepper) {
        periodEndMinutes.fadeTransition(0.2)
        if Int(periodEndStepper.value) == 1 {
            periodEndMinutes.text = String(Int(periodEndStepper.value)) + " Minute Before End"
        } else {
            periodEndMinutes.text = String(Int(periodEndStepper.value)) + " Minutes Before End"
        }
        saveEnabled = true
        saveButton.isEnabled = saveEnabled
        buttonColor()
    }
}

extension IndividualSettingController /*Alert Creation*/ {
    @IBAction func savePressed(_ sender: UIButton) {
        if saveEnabled {
            defaults.set(periodStartSwitch.isOn, forKey: "\(periodStringViaSegue) Start")
            defaults.set(periodStartStepper.value, forKey: "\(periodStringViaSegue) Start Minutes")
            defaults.set(periodEndSwitch.isOn, forKey: "\(periodStringViaSegue) End")
            defaults.set(periodEndStepper.value, forKey: "\(periodStringViaSegue) End Minutes")

            if periodStartSwitch.isOn {
                createNotfication(when: "Start", time: Int(periodStartStepper.value))
            } else {
                removeNotification(when: "Start")
            }
            if periodEndSwitch.isOn {
                createNotfication(when: "End", time: Int(periodEndStepper.value))
            } else {
                removeNotification(when: "End")
            }
            saveEnabled = false
            saveButton.isEnabled = saveEnabled
            saveButton.backgroundColor = .clear
        }
    }

    func currentSchedule() -> Int {
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day], from: now)
        let year =  components.year
        let month = components.month
        let day = components.day
        var currentSchedule = 0

        let c = NSDateComponents()
        c.year = 2017; c.month = 08; c.day = 15
        let schoolStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c as DateComponents)
        c.year = 2018; c.month = 06; c.day = 07
        let schoolEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c as DateComponents)

        if now.isBetweeen(date: schoolStart!, andDate: schoolEnd!) && now.weekday > 1 && now.weekday < 7 {
            for date in appDelegate.dateData {
                if date.year == year && date.month == month && date.day == day {
                    currentSchedule = date.schedule
                }
            }
        } else {
            currentSchedule = 3
        }

        return currentSchedule
    }

    func periodTimes(schedule: Int, when: String, time: Int) -> (Int, Int) {
        var hour: Int
        var minute: Int

        if schedule < 0 || schedule > 2 {
            return (0, 0)
        }

        if when == "Start" {
            hour = appDelegate.timeData[schedule].times.filter { $0.id == "p\(time)" }.first!.sh
            minute = appDelegate.timeData[schedule].times.filter { $0.id == "p\(time)" }.first!.sm
            if time <= minute {
                minute = minute-time
            } else {
                hour -= 1
                minute = 60-time
            }
        } else {
            hour = appDelegate.timeData[schedule].times.filter { $0.id == "p\(time)" }.first!.eh
            minute = appDelegate.timeData[schedule].times.filter { $0.id == "p\(time)" }.first!.em
            if time <= minute {
                minute = minute-time
            } else {
                hour -= 1
                minute = 60-time
            }
        }

        return (hour, minute)
    }

    func createNotfication(when: String, time: Int) {
        if #available(iOS 10.0, *) {
            newCreateAlert(when: when, time: time)
        } else {
            oldCreateAlert(when: when, time: time)
        }
    }

    @available(iOS 10.0, *)
    func newCreateAlert(when: String, time: Int) {
        let (hour, minute) = periodTimes(schedule: currentSchedule(), when: when, time: time)
        if hour == 0 && minute == 0 {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = periodStringViaSegue
        content.sound = UNNotificationSound.init(named: "bell_sound.caf")

        if when == "Start" {
            content.body = "Starts in \(time) minutes."
        } else {
            content.body = "Ends in \(time) minutes."
        }

        let date = DateComponents(hour: hour, minute: minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest.init(identifier: "\(periodStringViaSegue!) \(when)", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if error != nil {
                print(error!)
            }
        }
    }

    func oldCreateAlert(when: String, time: Int) {
        let (hour, minute) = periodTimes(schedule: currentSchedule(), when: when, time: time)
        if hour == 0 && minute == 0 {
            return
        }

        let c = NSDateComponents()
        c.hour = hour; c.minute = minute

        let notification = UILocalNotification()
        notification.alertTitle = periodStringViaSegue
        notification.soundName = "bell_sound.caf"

        if when == "Start" {
            notification.alertBody = "Starts in \(time) minutes."
        } else {
            notification.alertBody = "Ends in \(time) minutes."
        }

        notification.alertAction = "open"
        notification.fireDate = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c as DateComponents)
        notification.userInfo = ["Identifier": "\(self.periodStringViaSegue!) \(when)"]

        UIApplication.shared.scheduleLocalNotification(notification)
    }

    func removeNotification(when: String) {
        if #available(iOS 10.0, *) {
            newRemoveAlert(when: when)
        } else {
            oldRemoveAlert(when: when)
        }
    }

    @available(iOS 10.0, *)
    func newRemoveAlert(when: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
            var identifiers: [String] = []
            for notification: UNNotificationRequest in notificationRequests {
                if notification.identifier == "\(self.periodStringViaSegue!) \(when)" {
                    identifiers.append(notification.identifier)
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    func oldRemoveAlert(when: String) {
        for notification in UIApplication.shared.scheduledLocalNotifications! as [UILocalNotification] {
            if let info = notification.userInfo as? Dictionary<String, String> {
                if let s = info["Identifier"] {
                    if s == "\(self.periodStringViaSegue!) \(when)" {
                        UIApplication.shared.cancelLocalNotification(notification)
                    }
                }
            }
        }
    }
}
