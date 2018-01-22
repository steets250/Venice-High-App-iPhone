//
//  DetailViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 3/11/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import MessageUI
import PermissionScope
import SwiftMapVC
import SwiftWebVC

class DetailViewController: UIViewController {
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var fullStack: UIStackView!
    @IBOutlet var topSection: UIView!
    @IBOutlet var pageTitle: UILabel!
    @IBOutlet var tmSeperator: UIView!
    @IBOutlet var middleSection: UIStackView!
    @IBOutlet var mbSeperator: UIView!
    @IBOutlet var bottomSection: UIStackView!
    @IBOutlet var leftStack: UIStackView!
    @IBOutlet var rightStack: UIStackView!

    var type: String!
    var roomList = [Room]()
    var staffList = [Staff]()
    var staffViaSegue: Staff!
    var roomViaSegue: Room!
    var allowButtonsViaSegue = true
    var parentNameViaSegue = ""
    var textColor: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()
        staffList = appDelegate.staffData
        roomList = appDelegate.roomData

        if defaults.bool(forKey: "Is Dark") {
            mainView.backgroundColor = .darkGray
            tmSeperator.backgroundColor = .black
            mbSeperator.backgroundColor = .black
            textColor = .white
        } else {
            mainView.backgroundColor = .lightGray
            tmSeperator.backgroundColor = .white
            mbSeperator.backgroundColor = .white
            textColor = .black
        }

        pageTitle.adjustsFontSizeToFitWidth = true
        pageTitle.textColor = textColor

        if type == "Staff" {
            staffDidLoad()
        } else if type == "Room" {
            roomDidLoad()
        }
    }

}

extension DetailViewController /*Shared Functions*/ {
    func addButton(title: String, action: Selector) {
        if title != "" {
            let button = UIButton()
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = button.titleLabel?.font.withSize(20)
            button.setTitle(title, for: .normal)
            button.setTitleColor(appDelegate.themeBlue, for: .normal)
            button.addTarget(self, action: action, for: .touchUpInside)
            middleSection.addArrangedSubview(button)
        }
    }

    func addLabel(title: String) {
        if title != "" {
            let label = RegularLabel()
            label.textAlignment = .center
            label.font = label.font.withSize(20)
            label.textColor = textColor
            label.text = title
            middleSection.addArrangedSubview(label)
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
        pageTitle.text = "\(staffViaSegue.firstName) \(staffViaSegue.lastName)"
        if staffViaSegue.email != "" {
            addButton(title: "Email", action: #selector(emailAction))
        }
        if staffViaSegue.link != 0 {
            addButton(title: "Website", action: #selector(websiteAction))
        }
        middleSectionCheck()

        fullStack.addArrangedSubview(bottomSection)
        bottomSection.addArrangedSubview(leftStack)
        bottomSection.addArrangedSubview(rightStack)
        let s1Label = RegularLabel(); s1Label.text = "Period:"; s1Label.textColor = textColor; s1Label.textAlignment = .center; s1Label.font = s1Label.font.withSize(20)
        let s2Label = RegularLabel(); s2Label.text = "Room:"; s2Label.textColor = textColor; s2Label.textAlignment = .center; s2Label.font = s2Label.font.withSize(20)
        leftStack.addArrangedSubview(s1Label)
        rightStack.addArrangedSubview(s2Label)

        let periods = [staffViaSegue.p0, staffViaSegue.p1, staffViaSegue.p2, staffViaSegue.p3, staffViaSegue.p4, staffViaSegue.p5, staffViaSegue.p6, staffViaSegue.p7]
        var a: Int!; var b: Int!

        if defaults.bool(forKey: "Show Period 0") { a = 0 } else { a = 1 }
        if defaults.bool(forKey: "Show Period 7") { b = 7 } else { b = 6 }
        for period in a...b {
            let periodLabel = RegularLabel()
            let roomLabel = UIButton()
            let roomLabelDisable = RegularLabel()
            periodLabel.textAlignment = .center; roomLabelDisable.textAlignment = .center
            roomLabel.contentHorizontalAlignment = .center
            roomLabel.setTitleColor(appDelegate.themeBlue, for: .normal)
            periodLabel.textColor = textColor
            roomLabelDisable.textColor = textColor

            if periods[period] != "" {
                var temp: Any = roomLabel
                periodLabel.text = String(period)
                roomLabel.setTitle(periods[period], for: .normal)
                roomLabelDisable.text = periods[period]
                switch periods[period] {
                case "CONF", "/", "WASC", "UTLA", "RSP":
                    temp = roomLabelDisable
                default:
                    break
                }

                if allowButtonsViaSegue == false {
                    temp = roomLabelDisable
                }

                if roomLabelDisable.text == "CONF" {
                    roomLabelDisable.text = "Conference"
                }
                periodLabel.font = periodLabel.font.withSize(20)
                roomLabelDisable.font = roomLabelDisable.font.withSize(20)
                roomLabel.titleLabel!.font = roomLabel.titleLabel!.font.withSize(20)
                roomLabel.addTarget(self, action: #selector(openRoom), for: .touchUpInside)
                leftStack.addArrangedSubview(periodLabel)
                rightStack.addArrangedSubview(temp as! UIView)
            }
            if allowButtonsViaSegue == false {
                roomLabel.isUserInteractionEnabled = false; roomLabel.setTitleColor(textColor, for: .normal)
            }
        }
        var temp = 0
        for period in a...b {
            if periods[period] != "" {
                temp += 1
            }
        }
        if temp == 0 {
            s1Label.removeFromSuperview()
            s2Label.removeFromSuperview()
        }

        view.backgroundColor = .clear
        mainView.layer.cornerRadius = 10
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeAnimate))
        tap.delegate = self
        backgroundView.addGestureRecognizer(tap)
        showAnimate()
    }
}

extension DetailViewController /*Room View*/ {
    func roomDidLoad() {
        if CharacterSet.decimalDigits.contains(roomViaSegue.number.getFirst().unicodeScalars.first!) {
            pageTitle.text = "Room \(roomViaSegue.number)"
        } else {
            pageTitle.text = roomViaSegue.altid
        }
        if roomViaSegue.building != "" {
            addButton(title: "Location", action: #selector(openBuilding))
        }
        middleSectionCheck()

        let s1Label = RegularLabel(); s1Label.text = "Period:"; s1Label.textColor = textColor; s1Label.textAlignment = .center; s1Label.font = s1Label.font.withSize(20)
        let s2Label = RegularLabel(); s2Label.text = "Staff:"; s2Label.textColor = textColor; s2Label.textAlignment = .center; s2Label.font = s2Label.font.withSize(20)
        leftStack.addArrangedSubview(s1Label)
        rightStack.addArrangedSubview(s2Label)

        let period0 = defaults.bool(forKey: "Show Period 0")
        let period7 = defaults.bool(forKey: "Show Period 7")

        roomViaSegue.teachers = roomViaSegue.teachers.sorted { $0.period < $1.period }

        var skipped = 0
        for pair in roomViaSegue.teachers {
            if period0 == false && pair.period == "p0" {
                skipped += 1
                continue
            }
            if period7 == false && pair.period == "p7" {
                skipped += 1
                continue
            }
            let periodLabel = RegularLabel()
            let staffLabel = UIButton()
            let staffLabelDisable = RegularLabel()
            periodLabel.textAlignment = .center
            staffLabel.contentHorizontalAlignment = .center
            staffLabelDisable.textAlignment = .center
            periodLabel.font = periodLabel.font.withSize(20)
            staffLabel.titleLabel!.font = staffLabel.titleLabel!.font.withSize(20)
            staffLabelDisable.font = staffLabelDisable.font.withSize(20)
            staffLabel.titleLabel!.adjustsFontSizeToFitWidth = true
            staffLabelDisable.adjustsFontSizeToFitWidth = true
            staffLabel.setTitleColor(appDelegate.themeBlue, for: .normal)
            periodLabel.textColor = textColor
            staffLabelDisable.textColor = textColor

            let person = staffList.first(where: { $0.id == pair.teacherId })!
            let phrase = person.prefix + " " + person.lastName

            periodLabel.text = pair.period[1]
            staffLabel.setTitle(phrase, for: .normal)
            staffLabel.addTarget(self, action: #selector(openStaff), for: .touchUpInside)
            staffLabelDisable.text = phrase
            self.leftStack.addArrangedSubview(periodLabel)
            if allowButtonsViaSegue {
                self.rightStack.addArrangedSubview(staffLabel)
            } else {
                self.rightStack.addArrangedSubview(staffLabelDisable)
            }
        }

        if roomViaSegue.teachers.count-skipped == 0 {
            s1Label.removeFromSuperview()
            s2Label.removeFromSuperview()
        } else if roomViaSegue.teachers.count-skipped < 6 {
            for _ in roomViaSegue.teachers.count-skipped ..< 6 {
                self.leftStack.addArrangedSubview(UILabel())
                self.rightStack.addArrangedSubview(UILabel())
            }
        }

        self.view.backgroundColor = .clear
        mainView.layer.cornerRadius = 10
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeAnimate))
        tap.delegate = self
        self.backgroundView.addGestureRecognizer(tap)
        self.showAnimate()
    }
}

extension DetailViewController /*Action Functions*/ {
    func openRoom(sender: UIButton!) {
        let roomLabel = sender.titleLabel!.text!
        let room = roomList.filter({$0.number == roomLabel}).first!
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        popOverVC.type = "Room"
        popOverVC.roomViaSegue = room
        popOverVC.allowButtonsViaSegue = false
        addChildViewController(popOverVC)
        popOverVC.view.frame = view.frame
        view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }

    func websiteAction(sender: UIButton!) {
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
            let alertController = UIAlertController(title: "No Network", message: "Please connect your phone to a wifi or cellular network.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }

    func emailAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: staffViaSegue.email, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Copy to Clipboard", style: UIAlertActionStyle.default, handler: {_ in
            UIPasteboard.general.string = self.staffViaSegue.email
        }))
        if MFMailComposeViewController.canSendMail() {
            alertController.addAction(UIAlertAction(title: "Send Email", style: UIAlertActionStyle.default, handler: {_ in
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self
                mailComposerVC.setToRecipients([self.staffViaSegue.email])
                self.present(mailComposerVC, animated: true, completion: nil)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func openBuilding(_ sender: UIButton) {
        let building = roomViaSegue.building
        var floor: String!
        if roomViaSegue.floor == "1" {
            floor = "1st Floor"
        } else if roomViaSegue.floor == "2" {
            floor = "2nd Floor"
        }
        switch PermissionScope().statusLocationInUse() {
        case .unknown, .authorized:
            let pscope = PermissionScope()
            pscope.addPermission(LocationWhileInUsePermission(),
                                 message: "Shows you how to get\r\nto a building.")
            pscope.show({ _, _ in
                self.openMap(building: building, floor: floor)
            }, cancelled: { (_) -> Void in
                self.openMap(building: building, floor: floor)
            })
        case .unauthorized, .disabled:
            openMap(building: building, floor: floor)
            return
        }
    }

    func openMap(building: String, floor: String?) {
        let buildings = appDelegate.buildingData
        var longitude: Double!
        var latitude: Double!
        var pageTitle: String!
        if let location = buildings.filter({$0.name == building}).first {
            longitude = location.longitude
            latitude = location.latitude
            if floor != nil {
                pageTitle = "\(building): \(floor!)"
            } else {
                pageTitle = "\(building)"
            }
        }
        if defaults.bool(forKey: "Is Dark") {
            let mapVC = SwiftModalMapVC(name: pageTitle, latitude: latitude, longitude: longitude, theme: .dark)
            self.present(mapVC, animated: true, completion: nil)
        } else {
            let mapVC = SwiftModalMapVC(name: pageTitle, latitude: latitude, longitude: longitude, theme: .lightBlue)
            self.present(mapVC, animated: true, completion: nil)
        }
    }

    func openStaff(sender: UIButton!) {
        let staffLabel = sender.titleLabel!.text!
        let staff = staffList.filter({$0.prefix + " " + $0.lastName == staffLabel}).first!
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        popOverVC.type = "Staff"
        popOverVC.staffViaSegue = staff
        popOverVC.allowButtonsViaSegue = false
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == backgroundView {
            return true
        }
        return false
    }

    @IBAction func closePopUp(_ sender: AnyObject) {
        removeAnimate()
    }

    func showAnimate() {
        backgroundView.backgroundColor = .clear
        mainView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        mainView.alpha = 0.0
        UIView.animate(withDuration: 0.375, animations: {
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.mainView.alpha = 1.0
            self.mainView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }

    func removeAnimate() {
        UIView.animate(withDuration: 0.375, animations: {
            self.mainView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            self.mainView.alpha = 0.0
            self.backgroundView.backgroundColor = .clear
        }, completion: {(finished: Bool)  in
            if (finished) {
                self.view.removeFromSuperview()
            }
        })
    }
}

extension DetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
