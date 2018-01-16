//
//  BellViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 2/26/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import UIKit

class BellViewController: UIViewController {
    @IBOutlet weak var leftStack: UIStackView!
    @IBOutlet weak var rightStack: UIStackView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var timeLeft: UILabel!

    var color: UIColor = .black
    var scheduleTimer: Timer?
    var todayIndex = 1
    var checkIndex = ""
    let leftFiller = UILabel()
    let rightFiller = UILabel()
    var max = 0
    var show0: Bool!
    var show7: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()

        darkTheme()
        segmentSetup()
        todaySetup()

        show0 = defaults.bool(forKey: "Show Period 0")
        show7 = defaults.bool(forKey: "Show Period 7")

        timeLeft.textColor = color
        timeLeft.textAlignment = .center
        timeLeft.font = timeLeft.font.withSize(20)

        leftFiller.text = "EnoughText"
        leftFiller.alpha = 0.0

        rightFiller.text = "99:99 am - 99:99 pm"
        rightFiller.alpha = 0.0
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

    func darkTheme() {
        segmentedControl.tintColor = appDelegate.themeBlue
        if defaults.bool(forKey: "Is Dark") {
            self.view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            color = .white
        } else {
            self.view.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
            color = .black
        }
    }

    func segmentSetup() {
        var titles = [String]()
        for schedule in appDelegate.timeData {
            titles.append(schedule.schedule)
        }
        segmentedControl.replaceSegments(segments: titles)
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
                timeLeft.alpha = 0.0
                segmentedControl.selectedSegmentIndex = 0
            } else {
                segmentedControl.selectedSegmentIndex = todayIndex
            }
        } else {
            todayIndex = -1
            timeLeft.alpha = 0.0
            segmentedControl.selectedSegmentIndex = 0
        }
    }

    func runSchedule() {
        scheduleTimer?.invalidate()
        scheduleTimer = nil

        let currentSchedule = segmentedControl.selectedSegmentIndex
        let times = appDelegate.timeData[currentSchedule].times

        for object in leftStack.arrangedSubviews {
            let label = object as! UILabel
            if label.text != "Period X" {
                object.removeFromSuperview()
            } else {
                label.alpha = 0.0
            }
        }
        for object in rightStack.arrangedSubviews {
            let label = object as! UILabel
            if label.text != "XX:XX to XX:XX" {
                object.removeFromSuperview()
            } else {
                label.alpha = 0.0
            }
        }

        for time in times {
            if time.id.getFirst(2) != "pp" {
                if time.id.getLast() == "0" && defaults.bool(forKey: "Show Period 0") == false {
                    continue
                }
                if time.id.getLast() == "7" && defaults.bool(forKey: "Show Period 7") == false {
                    continue
                }

                let leftLabel = UILabel()
                leftLabel.textColor = color
                leftLabel.font = UIFont(name: "HelveticaNeue-Light", size: leftLabel.font.pointSize)
                leftLabel.textAlignment = .left
                leftLabel.text = time.title

                let rightLabel = UILabel()
                rightLabel.textColor = color
                rightLabel.font = UIFont(name: "HelveticaNeue-Light", size: rightLabel.font.pointSize)
                rightLabel.textAlignment = .left
                rightLabel.text = timeGenerator(time: time)

                if todayIndex == currentSchedule {
                    let start = Date().dateAt(hours: time.sh, minutes: time.sm)
                    let end = Date().dateAt(hours: time.eh, minutes: time.em)
                    let now = Date()

                    if now >= start && now <= end {
                        leftLabel.font = UIFont(name: "HelveticaNeue-Bold", size: leftLabel.font.pointSize)
                        rightLabel.font = UIFont(name: "HelveticaNeue-Bold", size: rightLabel.font.pointSize)
                        let minutes = now.minutes(from: end)*(0-1)
                        let seconds = now.seconds(from: end)*(0-1) - minutes*60
                        timeLeft.text = "Time Left: " + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
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
                        let minutes = now.minutes(from: end)*(0-1)
                        let seconds = now.seconds(from: end)*(0-1) - minutes*60
                        timeLeft.text = "\(time.title): " + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
                    }
                }
            }
        }

        if leftStack.arrangedSubviews.count < max {
            for _ in leftStack.arrangedSubviews.count ..< max {
                leftStack.addArrangedSubview(RegularLabel())
                rightStack.addArrangedSubview(RegularLabel())
            }
        }

        if todayIndex == currentSchedule && timeBetween(times) {
            timeLeft.alpha = 1
            self.scheduleTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(runSchedule), userInfo: nil, repeats: true)
        } else {
            timeLeft.alpha = 0
        }
    }

    func timeGenerator(time: Time) -> String {
        let start = twelveHour(time.sh, time.sm)
        let end = twelveHour(time.eh, time.em)
        return "\(start) to \(end)"
    }

    func twelveHour(_ h: Int, _ m: Int) -> String {
        var hh = h
        let mm = m
        var ap = "mm"

        if h == 0 {
            ap = "am"
            hh = 12
        }

        if h > 0 && h < 12 {
            ap = "am"
        }

        if h == 12 {
            ap = "pm"
        }

        if h > 12 {
            ap = "pm"
            hh = h - 12
        }
        return String(hh) + ":" + String(format: "%02d", mm) + " " + String(ap)
    }

    func timeBetween(_ input: [Time]) -> Bool {
        var times = [Time]()

        for time in input {
            if time.id.getLast() == "0" && defaults.bool(forKey: "Show Period 0") {
                times.append(time)
            } else if time.id.getLast() == "7" && defaults.bool(forKey: "Show Period 7") {
                times.append(time)
            } else {
                times.append(time)
            }
        }

        let calendar = Calendar.current
        let now = makeDate(calendar.component(.hour, from: Date()), calendar.component(.minute, from: Date()))

        if now >= makeDate(times.first!.sh, times.first!.sm) && now < makeDate(times.last!.eh, times.last!.em) {
            return true
        } else {
            return false
        }
    }

    func makeDate(_ hour: Int, _ minute: Int) -> Date {
        var c = DateComponents()
        c.hour = hour
        c.minute = minute
        let calendar = Calendar.current
        return calendar.date(from: c)!
    }

    @IBAction func showComponent(sender: UISegmentedControl) {
        runSchedule()
    }
}
