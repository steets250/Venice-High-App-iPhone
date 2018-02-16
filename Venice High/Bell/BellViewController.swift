//
//  BellViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 2/26/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import Cartography
import SwiftTheme
import UIKit

class BellViewController: UIViewController {
    var container: UIView!
    var segmentedControl: UISegmentedControl!
    var topArea: UIView!
    var timeLeft: UILabel!
    var bottomArea: UIView!
    var leftStack: UIStackView!
    var rightStack: UIStackView!

    var scheduleTimer: Timer?
    var todayIndex = 1
    var checkIndex = ""
    var max = 0
    var show0: Bool!
    var show7: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()

        Setup.page(self, title: "Bell Schedules", leftButton: UIBarButtonItem(image: UIImage(named: "Help"), style: .plain, target: self, action: #selector(openHelp)), rightButton: nil, largeTitle: true, back: false)

        show0 = defaults.bool(forKey: "Show Period 0")
        show7 = defaults.bool(forKey: "Show Period 7")

        pageSetup()
        visualSetup()
        todaySetup()
    }

    @objc func openHelp() {
        AlertScope.showAlert(.bellViewController, self)
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

        var titles = [String]()
        for schedule in appDelegate.timeData {
            titles.append(schedule.schedule)
        }
        segmentedControl = UISegmentedControl(items: titles)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(self.runSchedule), for: .valueChanged)
        segmentedControl.theme_tintColor = ThemeColorPicker(keyPath: "Global.themeBlue")
        self.navigationItem.titleView = segmentedControl

        topArea = UIView()
        topArea.backgroundColor = .clear
        bottomArea = UIView()
        bottomArea.backgroundColor = .clear
    }

    func visualSetup() {
        self.navigationController?.navigationBar.theme_tintColor = ThemeColorPicker(keyPath: "Global.themeBlue")
        self.view.theme_backgroundColor = ThemeColorPicker(keyPath: "Global.backgroundColor")
    }

    override func viewWillAppear(_ animated: Bool) {
        if defaults.bool(forKey: "Show Period 0") != show0 || defaults.bool(forKey: "Show Period 7") != show7 {
            show0 = defaults.bool(forKey: "Show Period 0")
            show7 = defaults.bool(forKey: "Show Period 7")
            max = 0
        }
        for schedule in appDelegate.timeData {
            var temp = 0
            for time in schedule.times {
                if time.id.getLast() == "0" && defaults.bool(forKey: "Show Period 0") == false {
                    continue
                }
                if time.id.getLast() == "7" && defaults.bool(forKey: "Show Period 7") == false {
                    continue
                }
                if time.id.getFirst(2) != "pp" {
                    temp += 1
                }
            }
            if temp > max {
                max = temp
            }
        }
        runSchedule()
    }

    func todaySetup() {
        let date = Date()
        if date.isBetween(date: appDelegate.schoolStart, andDate: appDelegate.schoolEnd) && date.weekday > 1 && date.weekday < 7 {
            let calendar = Calendar.current

            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)

            for date in appDelegate.dateData {
                if (year == date.year && month == date.month && day == date.day) {
                    todayIndex = date.schedule
                }
            }

            todayIndex -= 1

            if todayIndex == -1 {
                segmentedControl.selectedSegmentIndex = 0
            } else {
                segmentedControl.selectedSegmentIndex = todayIndex
            }
        } else {
            todayIndex = -1
            segmentedControl.selectedSegmentIndex = 0
        }
    }
}

extension BellViewController /*Schedule Functions*/ {
    func scheduleSetup() {
        if timeLeft != nil {
            timeLeft.removeFromSuperview()
        }
        topArea.removeFromSuperview()
        bottomArea.removeFromSuperview()

        let currentSchedule = segmentedControl.selectedSegmentIndex
        let times = appDelegate.timeData[currentSchedule].times
        if todayIndex == currentSchedule && timeBetween(times) {
            container.addSubview(topArea)
            constrain(topArea, container) { topArea, container in
                topArea.left == container.left + 16
                topArea.right == container.right - 16
                topArea.top == container.top
                topArea.height == container.height * 0.1
            }
            timeLeft = UILabel()
            timeLeft.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
            timeLeft.textAlignment = .center
            timeLeft.font = timeLeft.font.withSize(20)
            topArea.addSubview(timeLeft)
            constrain(timeLeft, topArea) { timeLeft, topArea in
                timeLeft.centerX == topArea.centerX
                timeLeft.centerY == topArea.centerY
            }
            view.addSubview(bottomArea)
            constrain(bottomArea, container) { bottomArea, container in
                bottomArea.left == container.left + 16
                bottomArea.right == container.right - 16
                bottomArea.bottom == container.bottom
                bottomArea.height == container.height * 0.9
            }
        } else {
            view.addSubview(bottomArea)
            constrain(bottomArea, container) { bottomArea, container in
                bottomArea.left == container.left + 16
                bottomArea.right == container.right - 16
                bottomArea.top == container.top
                bottomArea.bottom == container.bottom
            }
        }
    }

    @objc func runSchedule() {
        scheduleSetup()
        scheduleTimer?.invalidate()
        scheduleTimer = nil
        if leftStack != nil {
            leftStack.removeFromSuperview()
        }
        if rightStack != nil {
            rightStack.removeFromSuperview()
        }

        let currentSchedule = segmentedControl.selectedSegmentIndex
        let times = appDelegate.timeData[currentSchedule].times

        leftStack = UIStackView()
        leftStack.axis = .vertical
        leftStack.alignment = .fill
        leftStack.distribution = .fillEqually

        rightStack = UIStackView()
        rightStack.axis = .vertical
        rightStack.alignment = .fill
        rightStack.distribution = .fillEqually

        for time in times {
            if time.id.getFirst(2) != "pp" {
                if time.id.getLast() == "0" && defaults.bool(forKey: "Show Period 0") == false {
                    continue
                }
                if time.id.getLast() == "7" && defaults.bool(forKey: "Show Period 7") == false {
                    continue
                }

                let leftLabel = UILabel()
                leftLabel.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
                leftLabel.font = UIFont(name: "HelveticaNeue-Light", size: leftLabel.font.pointSize)
                leftLabel.textAlignment = .center
                leftLabel.text = time.title

                let rightLabel = UILabel()
                rightLabel.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
                rightLabel.font = UIFont(name: "HelveticaNeue-Light", size: rightLabel.font.pointSize)
                rightLabel.textAlignment = .center
                rightLabel.text = timeToString(time: time)

                if todayIndex == currentSchedule {
                    let start = Date().dateAt(hours: time.sh, minutes: time.sm)
                    let end = Date().dateAt(hours: time.eh, minutes: time.em)
                    let now = Date()

                    if now >= start && now <= end {
                        leftLabel.font = UIFont(name: "HelveticaNeue-Bold", size: leftLabel.font.pointSize)
                        rightLabel.font = UIFont(name: "HelveticaNeue-Bold", size: rightLabel.font.pointSize)
                        let minutes = now.minutes(from: end) * (0 - 1)
                        let seconds = now.seconds(from: end) * (0 - 1) - minutes * 60
                        timeLeft.text = "Time Left - " + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
                    }
                }

                leftStack.addArrangedSubview(leftLabel)
                rightStack.addArrangedSubview(rightLabel)
            } else {
                if time.id.getLast() == "0" && defaults.bool(forKey: "Show Period 0") == false {
                    continue
                }
                if time.id.getLast() == "7" && defaults.bool(forKey: "Show Period 7") == false {
                    continue
                }
                if todayIndex == currentSchedule {
                    let start = Date().dateAt(hours: time.sh, minutes: time.sm)
                    let end = Date().dateAt(hours: time.eh, minutes: time.em)
                    let now = Date()

                    if now >= start && now <= end {
                        let minutes = now.minutes(from: end) * (0 - 1)
                        let seconds = now.seconds(from: end) * (0 - 1) - minutes * 60
                        timeLeft.text = "\(time.title) - " + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
                    }
                }
            }
        }

        if leftStack.arrangedSubviews.count < max {
            for _ in leftStack.arrangedSubviews.count ..< max {
                leftStack.addArrangedSubview(UILabel())
                rightStack.addArrangedSubview(UILabel())
            }
        }

        bottomArea.addSubview(leftStack)
        constrain(leftStack, bottomArea) { leftStack, bottomArea in
            leftStack.left == bottomArea.left
            leftStack.width == bottomArea.width * 0.4
            leftStack.top == bottomArea.top
            leftStack.bottom == bottomArea.bottom
        }

        bottomArea.addSubview(rightStack)
        constrain(rightStack, bottomArea) { rightStack, bottomArea in
            rightStack.right == bottomArea.right
            rightStack.width == bottomArea.width * 0.6
            rightStack.top == bottomArea.top
            rightStack.bottom == bottomArea.bottom
        }

        if todayIndex == currentSchedule && timeBetween(times) {
            self.scheduleTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(runSchedule), userInfo: nil, repeats: true)
        }
    }

    @IBAction func showComponent(sender: UISegmentedControl) {
        runSchedule()
    }
}

extension BellViewController /*Helper Functions*/ {
    func timeToString(time: Time) -> String {
        let start = twelveHourString(time.sh, time.sm)
        let end = twelveHourString(time.eh, time.em)
        return "\(start) to \(end)"
    }

    func twelveHourString(_ hour: Int, _ minute: Int) -> String {
        var hh = hour
        let mm = minute
        var ap = "mm"

        if hour == 0 {
            ap = "am"
            hh = 12
        }

        if hour > 0 && hour < 12 {
            ap = "am"
        }

        if hour == 12 {
            ap = "pm"
        }

        if hour > 12 {
            ap = "pm"
            hh = hour - 12
        }
        return String(hh) + ":" + String(format: "%02d", mm) + " " + String(ap)
    }

    func timeBetween(_ input: [Time]) -> Bool {
        var times = [Time]()
        for time in input {
            if time.id.getLast() == "0" && defaults.bool(forKey: "Show Period 0") == false {
                continue
            }
            if time.id.getLast() == "7" && defaults.bool(forKey: "Show Period 7") == false {
                continue
            }
            times.append(time)
        }

        let calendar = Calendar.current
        let now = timeToDate(calendar.component(.hour, from: Date()), calendar.component(.minute, from: Date()))

        if now >= timeToDate(times.first!.sh, times.first!.sm) && now < timeToDate(times.last!.eh, times.last!.em) {
            return true
        } else {
            return false
        }
    }

    func timeToDate(_ hour: Int, _ minute: Int) -> Date {
        var c = DateComponents()
        c.hour = hour
        c.minute = minute
        let calendar = Calendar.current
        return calendar.date(from: c)!
    }
}
