//
//  Info.swift
//  Venice High
//
//  Created by Steven Steiner on 2/26/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import Cartography
import PermissionScope
import PMAlertController
import UserNotifications
import RFAboutView_Swift
import SwiftTheme
import SwiftWebVC

class InfoViewController: UIViewController {
    var container: UIView!
    var backgroundView: UIView!
    var backgroundImage: UIImageView!
    var tableView: UITableView!

    let colors = [ThemeColorPicker(keyPath: "Info.websiteColor"), ThemeColorPicker(keyPath: "Info.addressColor"), ThemeColorPicker(keyPath: "Info.phoneColor")]
    let actions = ["Website", "Address", "Phone"]
    let items = ["Show Period 0", "Show Period 7"]
    let defaults2 = UserDefaults.init(suiteName: "group.steets250.Venice-High.Bell-Schedule")!

    override func viewDidLoad() {
        super.viewDidLoad()

        Setup.page(self, title: "Info and Settings", leftButton: UIBarButtonItem(image: UIImage(named: "Help"), style: .plain, target: self, action: #selector(openHelp)), rightButton: UIBarButtonItem(image: UIImage(named: "Information"), style: .plain, target: self, action: #selector(information)), largeTitle: true, back: true)

        pageSetup()
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

        backgroundView = UIView(frame: container.frame)
        backgroundView.backgroundColor = .white
        backgroundImage = UIImageView(frame: view.frame)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.alpha = 1 / 3
        backgroundImage.contentMode = .scaleAspectFill
        backgroundView.addSubview(backgroundImage)
        container.addSubview(backgroundView)

        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.isOpaque = false
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "SegmentTableViewCell", bundle: nil), forCellReuseIdentifier: "segmentCell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "switchCell")
        container.addSubview(tableView)

        constrain(tableView, container) { tableView, container in
            tableView.edges == container.edges
        }
    }

    func visualSetup() {
        self.navigationController?.navigationBar.theme_tintColor = ThemeColorPicker(keyPath: "Global.themeBlue")
        self.view.theme_backgroundColor = ThemeColorPicker(keyPath: "Global.imageBackgroundColor")
        self.tableView.theme_separatorColor = ThemeColorPicker(keyPath: "Global.themeGray")
    }

    @objc func openHelp() {
        AlertScope.showAlert(.infoViewController, self)
    }
}

extension InfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = [3, 1, 1, 2]
        return sections[section]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat(7)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let aCell = UITableViewCell()
            aCell.textLabel!.text = actions[indexPath.row]
            aCell.textLabel!.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
            aCell.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 25.0)
            aCell.textLabel!.textAlignment = .center
            aCell.theme_backgroundColor = colors[indexPath.row]
            return aCell
        case 1:
            let aCell = tableView.dequeueReusableCell(withIdentifier: "segmentCell", for: indexPath) as! SegmentTableViewCell
            aCell.theme_backgroundColor = ThemeColorPicker(keyPath: "Info.cellColor")
            aCell.segmentedControl.theme_tintColor = ThemeColorPicker(keyPath: "Global.themeBlue")
            if defaults.bool(forKey: "Is Dark") {
                aCell.segmentedControl.selectedSegmentIndex = 1
            } else {
                aCell.segmentedControl.selectedSegmentIndex = 0
            }
            aCell.segmentedControl.addTarget(self, action: #selector(self.segment(sender:)), for: .valueChanged)
            aCell.selectionStyle = .none
            return aCell
        case 2:
            let aCell = UITableViewCell()
            aCell.accessoryType = .disclosureIndicator
            aCell.textLabel!.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
            aCell.theme_backgroundColor = ThemeColorPicker(keyPath: "Info.cellColor")
            aCell.textLabel!.text = "Change Calendar"
            return aCell
        case 3:
            let aCell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
            aCell.switcher.isOn = defaults.bool(forKey: items[indexPath.row])
            aCell.switcher.tag = indexPath.row
            aCell.switcher.addTarget(self, action: #selector(self.visual(sender:)), for: .valueChanged)
            aCell.titleLabel.text = self.items[indexPath.row]
            aCell.titleLabel.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
            aCell.selectionStyle = .none
            aCell.theme_backgroundColor = ThemeColorPicker(keyPath: "Info.cellColor")
            return aCell
        default:
            let aCell = UITableViewCell()
            aCell.theme_backgroundColor = ThemeColorPicker(keyPath: "Info.cellColor")
            aCell.selectionStyle = .none
            return aCell
        }
    }
}

extension InfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            self.action(sender: indexPath)
        }
        if indexPath == IndexPath(row: 0, section: 2) {
            tableView.deselectRow(at: indexPath, animated: true)
            let pscope = ThemePermissionScope()
            pscope.addPermission(EventsPermission(), message: "Lets us add events\r\nto your calendar.")
            pscope.show({ _, _ in
                let cscope = CalendarScope()
                cscope.showAlert()
            }, cancelled: nil)
        }
    }

    func action(sender: IndexPath) {
        switch sender.row {
        case 0:
            self.website()
        case 1:
            self.address()
        case 2:
            self.telephone()
        default:
            return
        }
    }

    @objc func visual(sender: UISwitch) {
        switch sender.tag {
        case 0:
        defaults.set(sender.isOn, forKey: "Show Period 0")
        defaults2.set(sender.isOn, forKey: "Show Period 0")
        case 1:
        defaults.set(sender.isOn, forKey: "Show Period 7")
        defaults2.set(sender.isOn, forKey: "Show Period 7")
        default:
            return
        }
    }

    @objc func segment(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            defaults.set(false, forKey: "Is Dark")
            ThemeManager.setTheme(plistName: "Light", path: .mainBundle)
        } else {
            defaults.set(true, forKey: "Is Dark")
            ThemeManager.setTheme(plistName: "Dark", path: .mainBundle)
        }
    }

    func telephone() {
        let alertController = PMAlertController(title: "Phone", message: "(310) 577-4200", preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
        alertController.addAction(PMAlertAction(title: "Copy to Clipboard", style: PMAlertActionStyle.default, handler: {
            UIPasteboard.general.string = "3105774200"
        }))
        alertController.addAction(PMAlertAction(title: "Call the School", style: PMAlertActionStyle.default, handler: {
            UIApplication.shared.openURL(URL(string: "tel://3105774200")!)
        }))
        alertController.addAction(PMAlertAction(title: "Dismiss", style: PMAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func address() {
        let alertController = PMAlertController(title: "Address", message: "13000 Venice Blvd.\nLos Angeles, CA 90066", preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
        alertController.addAction(PMAlertAction(title: "Copy to Clipboard", style: PMAlertActionStyle.default, handler: {
            UIPasteboard.general.string = "13000 Venice Blvd., Los Angeles, CA 90066"
        }))
        alertController.addAction(PMAlertAction(title: "Get Directions", style: PMAlertActionStyle.default, handler: {
            UIApplication.shared.openURL(URL(string: "http://maps.apple.com/?q=" + "13000 Venice Blvd. 90066".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!)
        }))
        alertController.addAction(PMAlertAction(title: "Dismiss", style: PMAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func website() {
        if internet() {
            let url = "https://venicehs-lausd-ca.schoolloop.com/"
            if defaults.bool(forKey: "Is Dark") {
                let webVC = SwiftModalWebVC(urlString: url, theme: .dark, dismissButtonStyle: .arrow)
                self.present(webVC, animated: true, completion: nil)
            } else {
                let webVC = SwiftModalWebVC(urlString: url)
                self.present(webVC, animated: true, completion: nil)
            }
        } else {
            let alertController = PMAlertController(title: "No Network", message: "Please connect your phone to a wifi or cellular network.", preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
            alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @objc func information() {
        let aboutView = RFAboutViewController(
            copyrightHolderName: "Steven Steiner",
            contactEmail: "venicehighapp@gmail.com",
            contactEmailTitle: "App Feedback",
            websiteURL: URL(string: "http://venicehigh.steets250.com"),
            websiteURLTitle: "App Website")
        aboutView.buttonTintColor = appDelegate.themeBlue
        aboutView.contactEmailColor = appDelegate.themeBlue
        aboutView.websiteURLColor = appDelegate.themeBlue

        if defaults.bool(forKey: "Is Dark") {
            aboutView.blurAlpha = 0.75
            aboutView.tintColor = .white
            aboutView.buttonTintColor = .white
            aboutView.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1)
            aboutView.headerTextColor = .white
            aboutView.headerBorderColor = .darkGray
            aboutView.headerBackgroundColor = .black
            aboutView.acknowledgementsHeaderColor = .white
            aboutView.tableViewBackgroundColor = .black
            aboutView.tableViewTextColor = .white
            aboutView.blurColor = .black
            aboutView.tableViewSeparatorColor = UIColor.white.withAlphaComponent(0.5)
            aboutView.tableViewSelectionColor = .darkGray
        }

        aboutView.headerBackgroundImage = UIImage(named: "Acknowledgements")

        self.navigationController?.pushViewController(aboutView, animated: true)
    }
}
