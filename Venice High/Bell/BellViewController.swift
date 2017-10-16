//
//  BellViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 2/26/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import UIKit

class BellViewController: UIViewController {
    @IBOutlet weak var leftStack: UIStackView!; @IBOutlet weak var rightStack: UIStackView!
    @IBOutlet weak var inLeftStack: UIStackView!; @IBOutlet weak var inRightStack: UIStackView!
    @IBOutlet weak var period0: UILabel!; @IBOutlet weak var period0t: UILabel!
    @IBOutlet weak var period1: UILabel!; @IBOutlet weak var period1t: UILabel!
    @IBOutlet weak var period2: UILabel!; @IBOutlet weak var period2t: UILabel!
    @IBOutlet weak var nutrition: UILabel!; @IBOutlet weak var nutritiont: UILabel!
    @IBOutlet weak var period3: UILabel!; @IBOutlet weak var period3t: UILabel!
    @IBOutlet weak var period4: UILabel!; @IBOutlet weak var period4t: UILabel!
    @IBOutlet weak var lunch: UILabel!; @IBOutlet weak var luncht: UILabel!
    @IBOutlet weak var period5: UILabel!; @IBOutlet weak var period5t: UILabel!
    @IBOutlet weak var period6: UILabel!; @IBOutlet weak var period6t: UILabel!
    @IBOutlet weak var period7: UILabel!; @IBOutlet weak var period7t: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var collectionOfLabels: Array<UILabel>?
    @IBOutlet var timeLeft: UILabel!

    var sstah: Int!; var sstam: Int!; var eendh: Int!; var eendm: Int!
    var leftArrays: Array<UILabel>!; var rightArrays: Array<UILabel>!
    var leftRegular  = ["Period 0", "Period 1", "Period 2", "Nutrition", "Period 3", "Period 4", "Lunch", "Period 5", "Period 6", "Period 7"]
    var rightRegular  = ["7:00 am - 7:51 am", "7:57 am - 8:53 am", "8:59 am - 10:09 am", "10:09 am - 10:26 am", "10:32 am - 11:27 am", "11:33 am - 12:28 pm", "12:28 pm - 1:01 pm", "1:07 pm - 2:02 pm", "2:08 pm - 3:04 pm", "3:10 pm - 4:30 pm"]
    var leftProfessional  = ["Period 0", "Period 1", "Period 2", "Nutrition", "Period 3", "Period 4", "Lunch", "Period 5", "Period 6", ""]
    var rightProfessional  = ["7:00 am - 7:57 am", "7:57 am - 8:38 am", "8:44 am - 9:39 am", "9:39 am - 9:56 am", "10:02 am - 10:43 am", "10:49 am - 11:29 am", "11:29 am - 12:02 pm", "12:08 pm - 12:48 pm", "12:54 pm -  1:34 pm", ""]
    var leftMinimum  = ["Period 0", "Period 1", "Period 2", "Period 3", "Nutrition", "Period 4", "Period 5", "Period 6", "Period 7", ""]
    var rightMinimum  = ["7:00 am - 7:51 am", "7:57 am - 8:33 am", "8:39 am - 9:29 am", "9:35 am - 10:11 am", "10:11 am - 10:28 am", "10:34 am - 11:10 am", "11:16 am - 11:52 am", "11:58 am - 12:34 pm", "12:41 pm - 1:04 pm", ""]

    var color: UIColor = .black
    var scheduleTimer: Timer?
    var todaySchedule = 0
    let leftFiller = UILabel()
    let rightFiller = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        sstah = 07; sstam = 00
        segmentedControl.tintColor = appDelegate.themeBlue
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let year =  components.year!; let month = components.month!; let day = components.day!

        leftArrays =  [period0, period1, period2, nutrition, period3, period4, lunch, period5, period6, period7]
        rightArrays = [period0t, period1t, period2t, nutritiont, period3t, period4t, luncht, period5t, period6t, period7t]

        darkTheme()
        schoolYear()

        timeLeft.textColor = color
        timeLeft.textAlignment = .center
        timeLeft.font = timeLeft.font.withSize(20)

        leftFiller.text = "EnoughText"
        leftFiller.alpha = 0.0

        rightFiller.text = "99:99 am - 99:99 pm"
        rightFiller.alpha = 0.0

        var match = false
        for date in appDelegate.dateData {
            if (year == date.year && month == date.month && day == date.day) {
                todaySchedule = date.schedule
                setSchedule(view: date.schedule)
                match = true
            }
        }
        if match == false {
            setSchedule(view: 0)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        setSchedule(view: segmentedControl.selectedSegmentIndex)
    }

    func setSchedule(view: Int) {
        scheduleTimer?.invalidate()
        scheduleTimer = nil
        segmentedControl.fadeTransition(0.5)
        segmentedControl.selectedSegmentIndex = view
        for obj in leftArrays! { self.inLeftStack.removeArrangedSubview(obj) }
        for obj in rightArrays! { self.inRightStack.removeArrangedSubview(obj) }
        self.inLeftStack.removeArrangedSubview(leftFiller)
        self.inRightStack.removeArrangedSubview(rightFiller)
        for obj in leftArrays! {obj.font = UIFont(name: "HelveticaNeue-Light", size: obj.font.pointSize)}
        for obj in rightArrays! {obj.font = UIFont(name: "HelveticaNeue-Light", size: obj.font.pointSize)}
        for obj in leftArrays! { self.inLeftStack.addArrangedSubview(obj) }
        for obj in rightArrays! { self.inRightStack.addArrangedSubview(obj) }
        self.inLeftStack.addArrangedSubview(leftFiller)
        self.inRightStack.addArrangedSubview(rightFiller)
        if defaults.bool(forKey: "Show Period 0") == false {
            self.inLeftStack.removeArrangedSubview(period0)
            self.inRightStack.removeArrangedSubview(period0t)
            period0.textColor = .clear; period0t.textColor = .clear
        } else {
            period0.textColor = color; period0t.textColor = color
        }
        if defaults.bool(forKey: "Show Period 7") == false {
            self.inLeftStack.removeArrangedSubview(period7)
            self.inRightStack.removeArrangedSubview(period7t)
            period7.textColor = .clear; period7t.textColor = .clear
        } else {
            period7.textColor = color; period7t.textColor = color
        }

        switch view {
        case 0:
            for array in self.leftArrays! {
                array.fadeTransition(0.5)
                array.text = self.leftRegular[self.leftArrays!.index(of: array)!]}
            for array in self.rightArrays! {
                array.fadeTransition(0.5)
                array.text = self.rightRegular[self.rightArrays!.index(of: array)!]}
            self.regularSchedule()
            self.scheduleTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BellViewController.regularSchedule), userInfo: nil, repeats: true)
        case 1:
            for array in self.leftArrays! {
                array.fadeTransition(0.5)
                array.text = self.leftProfessional[self.leftArrays!.index(of: array)!]}
            for array in self.rightArrays! {
                array.fadeTransition(0.5)
                array.text = self.rightProfessional[self.rightArrays!.index(of: array)!]
            }
            self.professionalSchedule()
            self.scheduleTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BellViewController.professionalSchedule), userInfo: nil, repeats: true)
        case 2:
            for array in self.leftArrays! {
                array.fadeTransition(0.5)
                array.text = self.leftMinimum[self.leftArrays!.index(of: array)!]}
            for array in self.rightArrays! {
                array.fadeTransition(0.5)
                array.text = self.rightMinimum[self.rightArrays!.index(of: array)!]
            }
            self.minimumSchedule()
            self.scheduleTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(BellViewController.minimumSchedule), userInfo: nil, repeats: true)
        default:
            break
        }

        if defaults.bool(forKey: "Show Period 7") == false {
            if view == 2 {
                period6.text = ""
                period6t.text = ""
            }
        }
        if todaySchedule != view {
            scheduleTimer?.invalidate()
            timeLeft.alpha = 0.0
        }
    }

    func notSchool(stah: Int, stam: Int, endh: Int, endm: Int) {
        let now = Date()
        if now > now.dateAt(hours: stah, minutes: stam) && now < now.dateAt(hours: endh, minutes: endm) && defaults.bool(forKey: "School Year") {
            timeLeft.alpha = 1.0
        } else {
            timeLeft.alpha = 0.0
        }
    }

    func darkTheme() {
        if defaults.bool(forKey: "Is Dark") {
            self.view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            color = .white
            for label in collectionOfLabels! {
                label.textColor = .white
            }
        } else {
            self.view.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
            color = .black
            for label in collectionOfLabels! {
                label.textColor = .black
            }
        }
        for label in collectionOfLabels! {
            label.textColor = color
        }
    }

    func regularSchedule() {
        let now = Date()
        if defaults.bool(forKey: "Show Period 7") {eendh = 16; eendm = 30} else {eendh = 15; eendm = 04}
        notSchool(stah: sstah, stam: sstam, endh: eendh, endm: eendm)
        if defaults.bool(forKey: "School Year") && todaySchedule == 0 {
            if defaults.bool(forKey: "Show Period 0") {
                scheduleCheck(pcs: now.dateAt(hours: 07, minutes: 00), pce: now.dateAt(hours: 07, minutes: 51), label: period0, label2: period0t)
                passing(pcs: now.dateAt(hours: 07, minutes: 51), pce: now.dateAt(hours: 07, minutes: 57))
            } else {
                passing(pcs: now.dateAt(hours: 07, minutes: 00), pce: now.dateAt(hours: 07, minutes: 57))
            }
            scheduleCheck(pcs: now.dateAt(hours: 07, minutes: 57), pce: now.dateAt(hours: 08, minutes: 53), label: period1, label2: period1t)
            passing(pcs: now.dateAt(hours: 08, minutes: 53), pce: now.dateAt(hours: 08, minutes: 59))
            scheduleCheck(pcs: now.dateAt(hours: 08, minutes: 59), pce: now.dateAt(hours: 10, minutes: 09), label: period2, label2: period2t)
            scheduleCheck(pcs: now.dateAt(hours: 10, minutes: 09), pce: now.dateAt(hours: 10, minutes: 26), label: nutrition, label2: nutritiont)
            passing(pcs: now.dateAt(hours: 10, minutes: 26), pce: now.dateAt(hours: 10, minutes: 32))
            scheduleCheck(pcs: now.dateAt(hours: 10, minutes: 32), pce: now.dateAt(hours: 11, minutes: 27), label: period3, label2: period3t)
            passing(pcs: now.dateAt(hours: 11, minutes: 27), pce: now.dateAt(hours: 11, minutes: 33))
            scheduleCheck(pcs: now.dateAt(hours: 11, minutes: 33), pce: now.dateAt(hours: 12, minutes: 28), label: period4, label2: period4t)
            scheduleCheck(pcs: now.dateAt(hours: 12, minutes: 28), pce: now.dateAt(hours: 13, minutes: 01), label: lunch, label2: luncht)
            passing(pcs: now.dateAt(hours: 13, minutes: 01), pce: now.dateAt(hours: 13, minutes: 07))
            scheduleCheck(pcs: now.dateAt(hours: 13, minutes: 07), pce: now.dateAt(hours: 14, minutes: 02), label: period5, label2: period5t)
            passing(pcs: now.dateAt(hours: 14, minutes: 02), pce: now.dateAt(hours: 14, minutes: 08))
            scheduleCheck(pcs: now.dateAt(hours: 14, minutes: 08), pce: now.dateAt(hours: 15, minutes: 04), label: period6, label2: period6t)
            if defaults.bool(forKey: "Show Period 7") {
                passing(pcs: now.dateAt(hours: 15, minutes: 04), pce: now.dateAt(hours: 15, minutes: 10))
                scheduleCheck(pcs: now.dateAt(hours: 15, minutes: 10), pce: now.dateAt(hours: 16, minutes: 30), label: period7, label2: period7t)
            }
        }
    }

    func professionalSchedule() {
        let now = Date()
        notSchool(stah: sstah, stam: sstam, endh: 13, endm: 34)
        if defaults.bool(forKey: "School Year") && todaySchedule == 1 {
            if defaults.bool(forKey: "Show Period 0") {
                scheduleCheck(pcs: now.dateAt(hours: 07, minutes: 00), pce: now.dateAt(hours: 07, minutes: 51), label: period0, label2: period0t)
                passing(pcs: now.dateAt(hours: 07, minutes: 51), pce: now.dateAt(hours: 07, minutes: 57))
            } else {
                passing(pcs: now.dateAt(hours: 07, minutes: 00), pce: now.dateAt(hours: 07, minutes: 57))
            }
            scheduleCheck(pcs: now.dateAt(hours: 07, minutes: 57), pce: now.dateAt(hours: 08, minutes: 38), label: period1, label2: period1t)
            passing(pcs: now.dateAt(hours: 08, minutes: 38), pce: now.dateAt(hours: 08, minutes: 44))
            scheduleCheck(pcs: now.dateAt(hours: 08, minutes: 44), pce: now.dateAt(hours: 09, minutes: 39), label: period2, label2: period2t)
            scheduleCheck(pcs: now.dateAt(hours: 09, minutes: 39), pce: now.dateAt(hours: 09, minutes: 56), label: nutrition, label2: nutritiont)
            passing(pcs: now.dateAt(hours: 09, minutes: 56), pce: now.dateAt(hours: 10, minutes: 02))
            scheduleCheck(pcs: now.dateAt(hours: 10, minutes: 02), pce: now.dateAt(hours: 10, minutes: 43), label: period3, label2: period3t)
            passing(pcs: now.dateAt(hours: 10, minutes: 43), pce: now.dateAt(hours: 10, minutes: 49))
            scheduleCheck(pcs: now.dateAt(hours: 10, minutes: 49), pce: now.dateAt(hours: 11, minutes: 29), label: period4, label2: period4t)
            scheduleCheck(pcs: now.dateAt(hours: 11, minutes: 29), pce: now.dateAt(hours: 12, minutes: 02), label: lunch, label2: luncht)
            passing(pcs: now.dateAt(hours: 12, minutes: 02), pce: now.dateAt(hours: 12, minutes: 24))
            scheduleCheck(pcs: now.dateAt(hours: 12, minutes: 24), pce: now.dateAt(hours: 13, minutes: 09), label: period5, label2: period5t)
            passing(pcs: now.dateAt(hours: 13, minutes: 09), pce: now.dateAt(hours: 12, minutes: 54))
            scheduleCheck(pcs: now.dateAt(hours: 12, minutes: 54), pce: now.dateAt(hours: 13, minutes: 34), label: period6, label2: period6t)
        }
    }

    func minimumSchedule() {
        let now = Date()
        if defaults.bool(forKey: "Show Period 7") {eendh = 13; eendm = 04} else {eendh = 12; eendm = 34}
        notSchool(stah: sstah, stam: sstam, endh: eendh, endm: eendm)
        if defaults.bool(forKey: "School Year") && todaySchedule == 2 {
            if defaults.bool(forKey: "Show Period 0") {
                scheduleCheck(pcs: now.dateAt(hours: 07, minutes: 00), pce: now.dateAt(hours: 07, minutes: 51), label: period0, label2: period0t)
                passing(pcs: now.dateAt(hours: 07, minutes: 51), pce: now.dateAt(hours: 07, minutes: 57))
            } else {
                passing(pcs: now.dateAt(hours: 07, minutes: 00), pce: now.dateAt(hours: 07, minutes: 57))
            }
            scheduleCheck(pcs: now.dateAt(hours: 07, minutes: 57), pce: now.dateAt(hours: 08, minutes: 33), label: period1, label2: period1t)
            passing(pcs: now.dateAt(hours: 08, minutes: 33), pce: now.dateAt(hours: 08, minutes: 39))
            scheduleCheck(pcs: now.dateAt(hours: 08, minutes: 39), pce: now.dateAt(hours: 09, minutes: 29), label: period2, label2: period2t)
            passing(pcs: now.dateAt(hours: 09, minutes: 29), pce: now.dateAt(hours: 09, minutes: 35))
            scheduleCheck(pcs: now.dateAt(hours: 09, minutes: 35), pce: now.dateAt(hours: 10, minutes: 11), label: nutrition, label2: nutritiont)
            scheduleCheck(pcs: now.dateAt(hours: 10, minutes: 11), pce: now.dateAt(hours: 10, minutes: 28), label: period3, label2: period3t)
            passing(pcs: now.dateAt(hours: 10, minutes: 28), pce: now.dateAt(hours: 10, minutes: 34))
            scheduleCheck(pcs: now.dateAt(hours: 10, minutes: 34), pce: now.dateAt(hours: 11, minutes: 10), label: period4, label2: period4t)
            passing(pcs: now.dateAt(hours: 11, minutes: 10), pce: now.dateAt(hours: 11, minutes: 16))
            scheduleCheck(pcs: now.dateAt(hours: 11, minutes: 16), pce: now.dateAt(hours: 11, minutes: 52), label: lunch, label2: luncht)
            passing(pcs: now.dateAt(hours: 11, minutes: 52), pce: now.dateAt(hours: 11, minutes: 58))
            scheduleCheck(pcs: now.dateAt(hours: 11, minutes: 58), pce: now.dateAt(hours: 12, minutes: 34), label: period5, label2: period5t)
            if defaults.bool(forKey: "Show Period 7") {
                passing(pcs: now.dateAt(hours: 12, minutes: 34), pce: now.dateAt(hours: 12, minutes: 41))
                scheduleCheck(pcs: now.dateAt(hours: 12, minutes: 41), pce: now.dateAt(hours: 13, minutes: 04), label: period6, label2: period6t)
            } else {
                period7.text = ""; period7t.text = ""
            }
        }
    }

    func scheduleCheck(pcs: Date, pce: Date, label: UILabel, label2: UILabel) {
        let now = Date()
        if now >= pcs && now <= pce {
            let minutes = now.minutes(from: pce)*(0-1)
            let seconds = now.seconds(from: pce)*(0-1) - minutes*60
            label.font = UIFont(name: "HelveticaNeue-Bold", size: label.font.pointSize)
            label2.font = UIFont(name: "HelveticaNeue-Bold", size: label2.font.pointSize)
            timeLeft.text = "Time Left: " + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        } else {
            label.font = UIFont(name: "HelveticaNeue-Light", size: label.font.pointSize)
            label2.font = UIFont(name: "HelveticaNeue-Light", size: label2.font.pointSize)
        }
    }

    func passing(pcs: Date, pce: Date) {
        let now = Date()
        if now >= pcs && now <= pce {
            let minutes = now.minutes(from: pce)*(0-1)
            let seconds = now.seconds(from: pce)*(0-1) - minutes*60
            timeLeft.text = "Passing Period: " + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        }
    }

    func schoolYear() {
        let now = Date()
        let c = NSDateComponents()
        c.year = 2017; c.month = 08; c.day = 15
        let schoolStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c as DateComponents)
        c.year = 2018; c.month = 06; c.day = 07
        let schoolEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c as DateComponents)
        if now.isBetweeen(date: schoolStart!, andDate: schoolEnd!) && now.weekday > 1 && now.weekday < 7 {
            defaults.set(true, forKey: "School Year")
        } else {
            defaults.set(false, forKey: "School Year")
        }
    }

    @IBAction func showComponent(sender: UISegmentedControl) {
        timeLeft.fadeTransition(0.5)
        setSchedule(view: sender.selectedSegmentIndex)
    }
}
