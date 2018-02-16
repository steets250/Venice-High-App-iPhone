//
//  DetailViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 3/11/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import Cartography
import MessageUI
import PermissionScope
import PMAlertController
import SwiftMapVC
import SwiftTheme
import SwiftWebVC

class DetailViewController: UIViewController {
    var container: UIView!
    var fullStack: UIStackView!
    var middleSection: UIStackView!
    var mbSeperator: UIView!
    var bottomSection: UIStackView!
    var leftStack: UIStackView!
    var rightStack: UIStackView!

    var type: DetailViewType
    var staffViaSegue: Staff!
    var roomViaSegue: Room!

    var textColor: UIColor!
    var roomList = [Room]()
    var staffList = [Staff]()
    var allowButtonsViaSegue = true
    var parentNameViaSegue = ""
    var emailShortcut: (() -> Void)?
    var websiteShortcut: (() -> Void)?
    var locationShortcut: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        Setup.page(self, title: nil, leftButton: nil, rightButton: UIBarButtonItem(image: UIImage(named: "Help"), style: .plain, target: self, action: #selector(openHelp)), largeTitle: false, back: true)

        staffList = appDelegate.staffData
        roomList = appDelegate.roomData

        pageSetup()
    }

    required init(type: DetailViewType, staff: Staff?, room: Room?, buttons: Bool) {
        self.type = type
        self.staffViaSegue = staff
        self.roomViaSegue = room
        self.allowButtonsViaSegue = buttons
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fullStack.removeFromSuperview()

        pageSetup()
        visualSetup()
        if type == .staff {
            staffDidLoad()
        }
        if type == .room {
            roomDidLoad()
        }
    }

    @objc func doneButtonTapped() {
        self.dismiss(animated: true, completion: nil)
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

        fullStack = UIStackView(frame: container.frame)
        fullStack.axis = .vertical
        fullStack.alignment = .fill
        fullStack.distribution = .fill
        container.addSubview(fullStack)

        constrain(fullStack, container) { fullStack, container in
            fullStack.edges == container.edges
        }

        middleSection = UIStackView()
        middleSection.axis = .vertical
        middleSection.alignment = .fill
        middleSection.distribution = .fillEqually
        fullStack.addArrangedSubview(middleSection)

        constrain(middleSection, fullStack) { middleSection, fullStack in
            middleSection.height == fullStack.height * 0.2
        }

        mbSeperator = UIView()
        fullStack.addArrangedSubview(mbSeperator)

        constrain(mbSeperator) { mbSeperator in
            mbSeperator.height == 2
        }

        bottomSection = UIStackView()
        bottomSection.axis = .horizontal
        bottomSection.alignment = .fill
        bottomSection.distribution = .fillEqually
        fullStack.addArrangedSubview(bottomSection)

        leftStack = UIStackView()
        leftStack.axis = .vertical
        leftStack.alignment = .fill
        leftStack.distribution = .fillEqually
        bottomSection.addArrangedSubview(leftStack)

        rightStack = UIStackView()
        rightStack.axis = .vertical
        rightStack.alignment = .fill
        rightStack.distribution = .fillEqually
        bottomSection.addArrangedSubview(rightStack)
    }

    func visualSetup() {
        self.navigationController?.navigationBar.theme_tintColor = ThemeColorPicker(keyPath: "Global.themeBlue")
        self.view.theme_backgroundColor = ThemeColorPicker(keyPath: "Global.backgroundColor")
        if defaults.bool(forKey: "Is Dark") {
            textColor = .white
            mbSeperator.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        } else {
            textColor = .black
            mbSeperator.backgroundColor = UIColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 1.0)
        }
    }

    override var previewActionItems: [UIPreviewActionItem] {
        if type == .staff {
            var actions = [UIPreviewAction]()
            if staffViaSegue?.email != "" {
                actions.append(UIPreviewAction(title: "Email", style: .default, handler: { (previewAction, viewController) in
                    self.emailShortcut?()
                }))
            }
            if staffViaSegue?.link != 0 {
                actions.append(UIPreviewAction(title: "Website", style: .default, handler: { (previewAction, viewController) in
                    self.websiteShortcut?()
                }))
            }
            return actions
        } else {
            var actions = [UIPreviewAction]()
            if roomViaSegue?.building != "" {
                actions.append(UIPreviewAction(title: "Location", style: .default, handler: { (previewAction, viewController) in
                    self.locationShortcut?()
                }))
            }
            return actions
        }
    }

    @objc func openHelp() {
        if staffViaSegue != nil {
            AlertScope.showAlert(.staffViewController, self)
        } else {
            AlertScope.showAlert(.roomViewController, self)
        }
    }
}

extension DetailViewController /*Shared Functions*/ {
    func addButton(title: String, action: Selector, view: UIStackView) {
        if title != "" {
            let button = UIButton()
            button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 20.0)!
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.contentHorizontalAlignment = .center
            button.setTitle(title, for: .normal)
            button.setTitleColor(appDelegate.themeBlue, for: .normal)
            button.addTarget(self, action: action, for: .touchUpInside)
            view.addArrangedSubview(button)
        }
    }

    func addLabel(title: String, view: UIStackView) {
        if title != "" {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont(name: "HelveticaNeue-Medium", size: 20.0)!
            label.textColor = textColor
            label.text = title
            label.adjustsFontSizeToFitWidth = true
            view.addArrangedSubview(label)
        }
    }

    func middleSectionCheck() {
        if middleSection.arrangedSubviews.isEmpty {
            middleSection.removeFromSuperview(); middleSection.alpha = 0.0
            mbSeperator.removeFromSuperview(); mbSeperator.alpha = 0.0
        }
    }
}

extension DetailViewController /*Staff View*/ {
    func staffDidLoad() {
        if defaults.bool(forKey: "🅱️") {
            self.navigationItem.title = "\("🅱️" + String(staffViaSegue.firstName.dropFirst())) \("🅱️" + String(staffViaSegue.lastName.dropFirst()))"
        } else {
            self.navigationItem.title = "\(staffViaSegue.firstName) \(staffViaSegue.lastName)"
        }
        if staffViaSegue.email != "" {
            addButton(title: "Email", action: #selector(emailAction), view: middleSection)
        }
        if staffViaSegue.link != 0 {
            addButton(title: "Website", action: #selector(websiteAction), view: middleSection)
        }
        middleSectionCheck()

        let periods = [staffViaSegue.p0, staffViaSegue.p1, staffViaSegue.p2, staffViaSegue.p3, staffViaSegue.p4, staffViaSegue.p5, staffViaSegue.p6, staffViaSegue.p7]

        var empty = true
        for period in 0...7 {
            if period == 0 && defaults.bool(forKey: "Show Period 0") == false {
                continue
            }
            if period == 7 && defaults.bool(forKey: "Show Period 7") == false {
                continue
            }
            if periods[period] != "" {
                empty = false
            }
        }

        if empty == false {
            addLabel(title: "Period:", view: leftStack)
            addLabel(title: "Room:", view: rightStack)

            for period in 0...7 {
                if period == 0 && defaults.bool(forKey: "Show Period 0") == false {
                    continue
                }
                if period == 7 && defaults.bool(forKey: "Show Period 7") == false {
                    continue
                }
                if periods[period] != "" {
                    var periodRoom = periods[period]
                    var disabled: Bool!

                    switch periodRoom {
                    case "CONF", "/", "WASC", "UTLA", "RSP":
                        disabled = true
                    default:
                        disabled = false
                    }

                    if periodRoom == "CONF" {
                        periodRoom = "Conference"
                    }

                    if allowButtonsViaSegue == false {
                        disabled = true
                    }

                    addLabel(title: String(period), view: leftStack)
                    if disabled {
                        addLabel(title: periodRoom, view: rightStack)
                    } else {
                        addButton(title: periodRoom, action: #selector(openRoom), view: rightStack)
                    }
                }
            }
        }
    }
}

extension DetailViewController /*Room View*/ {
    func roomDidLoad() {
        if CharacterSet.decimalDigits.contains(roomViaSegue.number.getFirst().unicodeScalars.first!) {
            self.navigationItem.title = "Room \(roomViaSegue.number)"
        } else {
            self.navigationItem.title = roomViaSegue.altid
        }
        if roomViaSegue.building != "" {
            addButton(title: "Location", action: #selector(openBuilding), view: middleSection)
        }
        middleSectionCheck()

        roomViaSegue.teachers = roomViaSegue.teachers.sorted { $0.period < $1.period }

        var skipped = 0

        for pair in roomViaSegue.teachers {
            if defaults.bool(forKey: "Show Period 0") == false && pair.period == "p0" {
                skipped += 1
                continue
            }
            if defaults.bool(forKey: "Show Period 7") == false && pair.period == "p7" {
                skipped += 1
                continue
            }
        }

        if roomViaSegue.teachers.count - skipped != 0 {
            addLabel(title: "Period:", view: leftStack)
            addLabel(title: "Staff:", view: rightStack)
            for pair in roomViaSegue.teachers {
                if defaults.bool(forKey: "Show Period 0") == false && pair.period == "p0" {
                    continue
                }
                if defaults.bool(forKey: "Show Period 7") == false && pair.period == "p7" {
                    continue
                }

                let person = staffList.first(where: { $0.id == pair.teacherId })!
                let phrase = person.prefix + " " + person.lastName

                addLabel(title: pair.period.getLast(), view: leftStack)

                if allowButtonsViaSegue {
                    addButton(title: phrase, action: #selector(openStaff), view: rightStack)
                } else {
                    addLabel(title: phrase, view: rightStack)
                }
            }
        }

        if roomViaSegue.teachers.count - skipped < 6 {
            for _ in roomViaSegue.teachers.count - skipped ..< 6 {
                self.leftStack.addArrangedSubview(UILabel())
                self.rightStack.addArrangedSubview(UILabel())
            }
        }
    }
}

extension DetailViewController /*Action Functions*/ {
    @objc func openRoom(sender: UIButton!) {
        let roomLabel = sender.titleLabel!.text!
        let room = roomList.filter({ $0.number == roomLabel }).first!
        let popOverVC = DetailViewController(type: .room, staff: nil, room: room, buttons: false)
        self.navigationController!.pushViewController(popOverVC, animated: true)
    }

    @objc func websiteAction() {
        if internet() {
            let url = "https://venicehs-lausd-ca.schoolloop.com/cms/user?d=x&group_id=" + String(staffViaSegue.link)
            if defaults.bool(forKey: "Is Dark") {
                let webVC = SwiftModalWebVC(urlString: url, theme: .dark, dismissButtonStyle: .arrow)
                present(webVC, animated: true, completion: nil)
            } else {
                let webVC = SwiftModalWebVC(urlString: url)
                present(webVC, animated: true, completion: nil)
            }
        } else {
            let alertController = PMAlertController(title: "No Network", message: "Please connect your phone to a wifi or cellular network.", preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
            alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }

    @objc func emailAction() {
        let alertController = PMAlertController(title: "Email", message: staffViaSegue.email, preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
        alertController.addAction(PMAlertAction(title: "Copy to Clipboard", style: PMAlertActionStyle.default, handler: {
            UIPasteboard.general.string = self.staffViaSegue.email
        }))
        if MFMailComposeViewController.canSendMail() {
            alertController.addAction(PMAlertAction(title: "Send Email", style: PMAlertActionStyle.default, handler: {
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self
                mailComposerVC.setToRecipients([self.staffViaSegue.email])
                self.present(mailComposerVC, animated: true, completion: nil)
            }))
        }
        alertController.addAction(PMAlertAction(title: "Dismiss", style: PMAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @objc func openBuilding() {
        switch ThemePermissionScope().statusLocationInUse() {
        case .unknown, .authorized:
            let pscope = ThemePermissionScope()
            pscope.addPermission(LocationWhileInUsePermission(), message: "Shows you how to get\r\nto a building.")
            pscope.show({ _, _ in
                self.openMap(room: self.roomViaSegue)
            }, cancelled: { (_) -> Void in
                self.openMap(room: self.roomViaSegue)
            })
        case .unauthorized, .disabled:
            openMap(room: self.roomViaSegue)
            return
        }
    }

    func openMap(room: Room) {
        var longitude: Double!
        var latitude: Double!
        if let building = appDelegate.buildingData.filter({ $0.name == room.building }).first {
            longitude = building.longitude
            latitude = building.latitude
        }
        var mapVC: SwiftModalMapVC!
        if defaults.bool(forKey: "Is Dark") {
            if room.altid == "" {
                mapVC = SwiftModalMapVC(room: room.number, building: room.building, floor: room.floor, latitude: latitude, longitude: longitude, theme: .dark)
            } else {
                mapVC = SwiftModalMapVC(room: room.altid, building: room.building, floor: room.floor, latitude: latitude, longitude: longitude, theme: .dark)
            }

        } else {
            if room.altid == "" {
                mapVC = SwiftModalMapVC(room: room.number, building: room.building, floor: room.floor, latitude: latitude, longitude: longitude, theme: .lightBlue)
            } else {
                mapVC = SwiftModalMapVC(room: room.altid, building: room.building, floor: room.floor, latitude: latitude, longitude: longitude, theme: .lightBlue)
            }
        }
        self.present(mapVC, animated: true, completion: nil)
    }

    @objc func openStaff(sender: UIButton!) {
        let staffLabel = sender.titleLabel!.text!
        let staff = staffList.filter({ $0.prefix + " " + $0.lastName == staffLabel }).first!
        let popOverVC = DetailViewController(type: .staff, staff: staff, room: nil, buttons: false)
        self.navigationController!.pushViewController(popOverVC, animated: true)
    }
}

extension DetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

enum DetailViewType: String {
    case staff = "staff"
    case room = "room"
}
