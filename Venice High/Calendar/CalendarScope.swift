//
//  CalendarScope.swift
//  Venice High
//
//  Created by Steven Steiner on 5/22/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import EventKit
import UIKit

class CalendarScope: UIViewController, UIGestureRecognizerDelegate {
    var headerLabel                  = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
    var bodyLabel                    = UILabel(frame: CGRect(x: 0, y: 0, width: 240, height: 70))
    var cancelButtonTextColor        = UIColor(red: 0, green: 0.47, blue: 1, alpha: 1)
    var buttonFont: UIFont           = .boldSystemFont(ofSize: 14)
    var labelFont: UIFont            = .systemFont(ofSize: 14)
    var cancelButton                 = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 25))
    var selectButton                 = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 25))
    var cancelOffset                 = CGSize.zero
    var pickerView                   = CustomPicker(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
    let baseView    = UIView()
    let contentView = UIView()
    var viewControllerForAlerts: UIViewController?

    let eventStore = EKEventStore()
    var pickerArray:[(name: String, selectable: Bool)] = []
    var nameSet = false

    public typealias finishedType = (_ finished: Bool) -> Void
    var onFinish: finishedType?

    init() {
        super.init(nibName: nil, bundle: nil)
        viewControllerForAlerts = self
        view.frame = UIScreen.main.bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        view.addSubview(baseView)
        baseView.frame = view.frame
        baseView.addSubview(contentView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        tap.delegate = self
        baseView.addGestureRecognizer(tap)

        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5

        headerLabel.font = UIFont.systemFont(ofSize: 22)
        headerLabel.textAlignment = NSTextAlignment.center
        headerLabel.text = "Calendar Setup"
        contentView.addSubview(headerLabel)

        bodyLabel.font = UIFont.boldSystemFont(ofSize: 16)
        bodyLabel.textAlignment = NSTextAlignment.center
        bodyLabel.text = "Please select a calendar\r\nor create a new one."
        bodyLabel.numberOfLines = 2
        contentView.addSubview(bodyLabel)

        pickerView.dataSource = self
        pickerView.delegate = self
        contentView.addSubview(pickerView)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(hide), for: .touchUpInside)
        contentView.addSubview(cancelButton)

        selectButton.titleLabel?.font = UIFont(name: (selectButton.titleLabel?.fontName)!, size: 25.0)
        selectButton.setTitle("Select", for: .normal)
        selectButton.addTarget(self, action: #selector(complete), for: .touchUpInside)
        contentView.addSubview(selectButton)

        if defaults.bool(forKey: "Is Dark") {
            contentView.backgroundColor = .black
            headerLabel.textColor = .white
            bodyLabel.textColor = .white
            pickerView.selectorColor = .white
            cancelButton.setTitleColor(appDelegate.themeBlue, for: .normal)
            selectButton.setTitleColor(appDelegate.themeBlue, for: .normal)
        } else {
            contentView.backgroundColor = .white
            headerLabel.textColor = .black
            bodyLabel.textColor = .black
            pickerView.selectorColor = .black
        }

        pickerArray.append((name: "Add New Calendar", selectable: true))
        var sourceList = eventStore.sources
        sourceList = sourceList.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending }
        for source in sourceList {
            if source.sourceType == .local || source.sourceType == .calDAV || source.sourceType == .exchange {
                pickerArray.append((name: source.title + ":", selectable: false))
                let calendarArray = source.calendars(for: .event)
                for calendar in calendarArray {
                    pickerArray.append((name: calendar.title, selectable: true))
                }
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let screenSize = UIScreen.main.bounds.size
        view.frame.size = screenSize
        let x = (screenSize.width - 280.0) / 2
        let y = (screenSize.height - 300.0) / 2

        contentView.frame = CGRect(x: x, y: y, width: 280.0, height: 300.0)

        headerLabel.center = contentView.center
        headerLabel.frame.offsetInPlace(dx: -contentView.frame.origin.x, dy: -contentView.frame.origin.y)
        headerLabel.frame.offsetInPlace(dx: 0, dy: -((300.0/2)-50))

        bodyLabel.center = contentView.center
        bodyLabel.frame.offsetInPlace(dx: -contentView.frame.origin.x, dy: -contentView.frame.origin.y)
        bodyLabel.frame.offsetInPlace(dx: 0, dy: -((300.0/2)-100))

        pickerView.center = contentView.center
        pickerView.frame.offsetInPlace(dx: -contentView.frame.origin.x, dy: -contentView.frame.origin.y)
        pickerView.frame.offsetInPlace(dx: 0, dy: -((300.0/2)-190))

        selectButton.center = contentView.center
        selectButton.frame.offsetInPlace(dx: -contentView.frame.origin.x, dy: -contentView.frame.origin.y)
        selectButton.frame.offsetInPlace(dx: 0, dy: -((300.0/2)-275))
        selectButton.setTitleColor(cancelButtonTextColor, for: .normal)

        cancelButton.center = contentView.center
        cancelButton.frame.offsetInPlace(dx: -contentView.frame.origin.x, dy: -contentView.frame.origin.y)
        cancelButton.frame.offsetInPlace(dx: 100, dy: -((300.0/2)-20))
        cancelButton.frame.offsetInPlace(dx: self.cancelOffset.width, dy: self.cancelOffset.height)
        cancelButton.setTitleColor(cancelButtonTextColor, for: .normal)
    }

    func showAlert(finished: finishedType? = nil) {
        onFinish = finished

        let window = UIApplication.shared.keyWindow!
        window.endEditing(true)
        window.addSubview(view)
        view.frame = window.bounds
        baseView.frame = window.bounds
        self.view.setNeedsLayout()
        self.baseView.frame.origin.y = self.view.bounds.origin.y - self.baseView.frame.size.height
        self.view.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
            self.baseView.center.y = window.center.y + 15
            self.view.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.baseView.center = window.center
            })
        })
    }

    func complete() {
        let row = pickerView.selectedRow(inComponent: 0)
        var customText = "Venice High School"
        if row == 0 && nameSet == false {
            let alert = UIAlertController(title: "New Calendar", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Venice High School"
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                if textField?.text != "" {
                    customText = (textField?.text!)!
                }
                self.nameSet = true
                self.pickerArray.remove(at: 0)
                self.pickerArray.insert((name: customText, selectable: true), at: 0)
                self.pickerView.reloadAllComponents()
            }))
            self.present(alert, animated: true, completion: nil)
        } else if row == 0 && nameSet {
            let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
            newCalendar.title = pickerArray[row].name
            newCalendar.source = eventStore.sources.filter {
                (source: EKSource) -> Bool in
                source.sourceType.rawValue == EKSourceType.calDAV.rawValue
                }.first!
            do {
                try eventStore.saveCalendar(newCalendar, commit: true)
                defaults.set(newCalendar.title, forKey: "Calendar Name")
                defaults.set(newCalendar.calendarIdentifier, forKey: "Calendar Identifier")
                self.hide()
            } catch {
                let alert = UIAlertController(title: "Calendar Error", message: (error as NSError).description.slice(from: "\"", to: "\"")!, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            defaults.set(pickerArray[row].name, forKey: "Calendar Name")
            for calendar in eventStore.calendars(for: .event) {
                if pickerArray[row].name == calendar.title {
                    defaults.set(calendar.calendarIdentifier, forKey: "Calendar Identifier")
                }
            }
            self.hide()
        }
    }

    func hide() {
        if defaults.string(forKey: "Calendar Name") != "" {
            if let onFinish = onFinish {
                onFinish(true)
            }
        } else {
            if let onFinish = onFinish {
                onFinish(false)
            }
        }
        let window = UIApplication.shared.keyWindow!
        DispatchQueue.main.async(execute: {
            UIView.animate(withDuration: 0.2, animations: {
                self.baseView.frame.origin.y = window.center.y + 400
                self.view.alpha = 0
            }, completion: { _ in
                self.view.removeFromSuperview()
            })
        })
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == baseView {
            return true
        }
        return false
    }
}

extension CalendarScope: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerArray[row].selectable == false {
            if pickerArray[row+1].selectable == false {
                pickerView.selectRow(row+2, inComponent: 0, animated: true)
            } else {
                pickerView.selectRow(row+1, inComponent: 0, animated: true)
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerArray[row].name
        let color: UIColor!
        if defaults.bool(forKey: "Is Dark") {
            color = .white
        } else {
            color = .black
        }
        let myTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName: color])
        return myTitle
    }
}
