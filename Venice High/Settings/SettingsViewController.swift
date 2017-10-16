//
//  SettingsViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 4/1/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import PermissionScope
import UserNotifications

class SettingsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var section = ["App Options", "Notifications"]
    var items = ["Dark Theme", "Show Period 0", "Show Period 7"]
    var times = ["Period 0", "Period 1", "Period 2", "Period 3", "Period 4", "Period 5", "Period 6", "Period 7"]
    var numbers = [0, 1, 2, 3, 4, 5, 6, 7]
    var buttons = ["Change Calendar"]
    let defaults2 = UserDefaults.init(suiteName: "group.steets250.Venice-High.Bell-Schedule")!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isScrollEnabled = false
        self.tableView.isOpaque = false
        self.tableView.backgroundView = nil
        if defaults.bool(forKey: "Is Dark") {
            self.tableView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        } else {
            self.tableView.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
        }
        if defaults.bool(forKey: "Show Period 0") == false {
            if let index = times.index(of: "Period 0") {
                times.remove(at: index)
                numbers.remove(at: index)
            }
        }
        if defaults.bool(forKey: "Show Period 7") == false {
            if let index = times.index(of: "Period 7") {
                times.remove(at: index)
                numbers.remove(at: index)
            }
        }
    }

    func visual(sender: UISwitch) {
        switch sender.tag {
        case 0:
            defaults.set(sender.isOn, forKey: "Dark Theme")
            if defaults.bool(forKey: "Is Dark") != sender.isOn {
                themeAlert()
            }
        case 1:
            defaults.set(sender.isOn, forKey: "Show Period 0")
            defaults2.set(sender.isOn, forKey: "Show Period 0")
            visualChange("Period 0", sender.isOn, 0)
        case 2:
            defaults.set(sender.isOn, forKey: "Show Period 7")
            defaults2.set(sender.isOn, forKey: "Show Period 7")
            visualChange("Period 7", sender.isOn, 7)
        default:
            return
        }
    }

    func visualChange(_ period: String, _ status: Bool, _ number: Int) {
        if status == false {
            defaults.set(false, forKey: "\(period) Start")
            defaults.set(Double(0), forKey: "\(period) Start Minutes")
            defaults.set(false, forKey: "\(period) End")
            defaults.set(Double(0), forKey: "\(period) End Minutes")
            removeNotification(when: "Start", period: number)
            removeNotification(when: "End", period: number)
        }
    }

    func removeNotification(when: String, period: Int) {
        if #available(iOS 10.0, *) {
            newRemoveAlert(when: when, period: period)
        } else {
            oldRemoveAlert(when: when, period: period)
        }
    }

    @available(iOS 10.0, *)
    func newRemoveAlert(when: String, period: Int) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
            var identifiers: [String] = []
            for notification: UNNotificationRequest in notificationRequests {
                if notification.identifier == "\(period) \(when)" {
                    identifiers.append(notification.identifier)
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    func oldRemoveAlert(when: String, period: Int) {
        for notification in UIApplication.shared.scheduledLocalNotifications! as [UILocalNotification] {
            if let info = notification.userInfo as? Dictionary<String, String> {
                if let s = info["Identifier"] {
                    if s == "\(period) \(when)" {
                        UIApplication.shared.cancelLocalNotification(notification)
                    }
                }
            }
        }
    }

    func themeAlert() {
        if defaults.bool(forKey: "Theme Alert") {
            let alertController = UIAlertController(title: nil, message: "Restart the app to update color scheme.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            alertController.addAction(UIAlertAction(title: "Don't Show Again", style: UIAlertActionStyle.cancel, handler: { _ in
                self.defaults.set(false, forKey: "Theme Alert")
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 3, section: 0) {
            tableView.deselectRow(at: indexPath, animated: true)
            let pscope = PermissionScope()
            pscope.addPermission(EventsPermission(), message: "Lets us add events\r\nto your calendar.")
            pscope.show({ _, _ in
                let cscope = CalendarScope()
                cscope.showAlert()
            }, cancelled: nil)
        }
        if indexPath.section == 1 {
            let pscope = PermissionScope()
            pscope.addPermission(NotificationsPermission(notificationCategories: nil),
                                 message: "Lets us send you\r\nbell notifications.")
            pscope.show({ _, _ in
                self.performSegue(withIdentifier: "showSetting", sender: self)

            }, cancelled: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showSetting") {
            let upcoming: IndividualSettingController = segue.destination as! IndividualSettingController
            let indexPath = self.tableView.indexPathForSelectedRow!
            upcoming.periodStringViaSegue = self.times[indexPath.row]
            upcoming.periodViaSegue = self.numbers[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let temp = [self.items.count + self.buttons.count, self.times.count]
        return temp[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 3 {
                let aCell = tableView.dequeueReusableCell(withIdentifier: "button", for: indexPath) as! ButtonTableViewCell
                if defaults.bool(forKey: "Is Dark") {
                    aCell.titleLabel.textColor = .white
                } else {
                    aCell.titleLabel.textColor = .black
                }
                aCell.backgroundColor = .clear
                aCell.titleLabel.text = self.buttons[indexPath.row-3]
                return aCell
            } else {
                let aCell = tableView.dequeueReusableCell(withIdentifier: "switcher", for: indexPath) as! SwitchTableViewCell
                if defaults.bool(forKey: "Is Dark") {
                    aCell.switcher.onTintColor = .lightGray
                    aCell.switcher.tintColor = .darkGray
                } else {
                    aCell.switcher.onTintColor = .darkGray
                    aCell.switcher.tintColor = .lightGray
                }
                aCell.switcher.isOn = defaults.bool(forKey: items[indexPath.row])
                aCell.switcher.tag = indexPath.row
                aCell.switcher.addTarget(self, action: #selector(self.visual(sender:)), for: .valueChanged)
                aCell.titleLabel.text = self.items[indexPath.row]
                aCell.selectionStyle = .none
                if defaults.bool(forKey: "Is Dark") {
                    aCell.titleLabel.textColor = .white
                } else {
                    aCell.titleLabel.textColor = .black
                }
                aCell.backgroundColor = .clear
                return aCell
            }
        case 1:
            let aCell = tableView.dequeueReusableCell(withIdentifier: "button", for: indexPath) as! ButtonTableViewCell
            aCell.titleLabel.text = self.times[indexPath.row]
            if defaults.bool(forKey: "Is Dark") {
                aCell.titleLabel.textColor = .white
            } else {
                aCell.titleLabel.textColor = .black
            }
            aCell.backgroundColor = .clear
            return aCell
        default:
            return UITableViewCell()
        }
    }
}
