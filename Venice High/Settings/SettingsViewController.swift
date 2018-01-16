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
    var items = ["Dark Theme", "Show Period 0", "Show Period 7"]
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
            self.tableView.separatorColor = .darkGray
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
        case 2:
            defaults.set(sender.isOn, forKey: "Show Period 7")
            defaults2.set(sender.isOn, forKey: "Show Period 7")
        default:
            return
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
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count + self.buttons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    }
}
