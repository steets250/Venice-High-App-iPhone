//
//  TodayViewController.swift
//  Bell Schedule
//
//  Created by Steven Steiner on 4/20/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import NotificationCenter
import ObjectMapper

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var currentSchedule: UILabel!
    
    let defaults = UserDefaults.init(suiteName: "group.steets250.Venice-High.Bell-Schedule")!
    let sstah = 07; let sstam = 00; var eendh: Int!; var eendm: Int!
    var starting: Int!; var ending: Int!; var schedule: Int!; var generalTimer: Timer?
    let titles = ["Regular Schedule", "Professional Schedule", "Minimum Schedule"]
    var dates = [YMD]()
    var schedules = [BellSchedule]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.string(forKey: "dateData") != nil {
            dates = Mapper<YMD>().mapArray(JSONString: defaults.string(forKey: "dateData")!)!
        }
        if defaults.string(forKey: "timeData") != nil {
            schedules = Mapper<BellSchedule>().mapArray(JSONString: defaults.string(forKey: "timeData")!)!
        }
        if dates.count == 0 || schedules.count == 0 {
            noData()
        } else {
            initialSchedule()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        initialSchedule()
    }

    func initialSchedule() {
        if UIDevice.current.systemVersion[UIDevice.current.systemVersion.startIndex] == "9" {
            period.textColor = .white; timeLeft.textColor = .white; currentSchedule.textColor = .white
        }
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        let year =  components.year; let month = components.month; let day = components.day
        let c = NSDateComponents()
        c.year = 2017; c.month = 08; c.day = 15
        let schoolStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c as DateComponents)
        c.year = 2018; c.month = 06; c.day = 07
        let schoolEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c as DateComponents)

        if now.weekday > 1 && now.weekday < 7 && now.isBetweeen(date: schoolStart!, andDate: schoolEnd!) {
            var match = false
            for i in dates {
                if (year == i.year && month == i.month && day == i.day) {schedule = i.schedule; match = true}
            }
            if match == false {schedule = 0}
            if schedule == 3 {
                noSchool()
            } else {
                currentSchedule.text = titles[schedule]
                generalSchedule()
                generalTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.generalSchedule), userInfo: nil, repeats: true)
            }
        } else {
            noSchool()
        }
    }

    func noData() {
        stackView.removeArrangedSubview(currentSchedule)
        currentSchedule.textColor = .clear
        stackView.removeArrangedSubview(timeLeft)
        timeLeft.textColor = .clear
        period.text = "Error Loading Data"
    }

    func noSchool() {
        stackView.removeArrangedSubview(currentSchedule)
        currentSchedule.textColor = .clear
        stackView.removeArrangedSubview(timeLeft)
        timeLeft.textColor = .clear
        period.text = "No School Today"
    }

    func generalSchedule() {
        if defaults.bool(forKey: "Show Period 0") {starting = 0} else {starting = 2}

        switch schedule {
        case 0:
            if defaults.bool(forKey: "Show Period 7") {eendh = 16; eendm = 30} else {eendh = 15; eendm = 04}
            notSchool(sstah, sstam, eendh, eendm)
            if defaults.bool(forKey: "Show Period 7") {ending = 17} else {ending = 15}
        case 1:
            notSchool(sstah, sstam, 13, 34)
            ending = 15
        case 2:
            if defaults.bool(forKey: "Show Period 7") {eendh = 13; eendm = 04} else {eendh = 12; eendm = 34}
            notSchool(sstah, sstam, eendh, eendm)
            if defaults.bool(forKey: "Show Period 7") {ending = 16} else {ending = 14}
        default:
            break
        }
        for i in starting...ending {
            if starting == 0 && i == 2 {
                continue
            }
            getSchedule(schedule, i)
        }
    }

    func notSchool(_ stah: Int, _ stam: Int, _ endh: Int, _ endm: Int) {
        let now = Date()
        if now > now.dateAt(endh, endm) {
            stackView.removeArrangedSubview(currentSchedule)
            currentSchedule.textColor = .clear
            stackView.removeArrangedSubview(timeLeft)
            timeLeft.textColor = .clear
            period.text = "School Has Ended"
            if generalTimer != nil {generalTimer?.invalidate(); generalTimer = nil}
        }

        if now < now.dateAt(stah, stam) {
            stackView.removeArrangedSubview(currentSchedule)
            currentSchedule.textColor = .clear
            stackView.removeArrangedSubview(timeLeft)
            timeLeft.textColor = .clear
            period.text = "School Hasn't Started"
        }
    }

    func getSchedule(_ day: Int, _ index: Int) {
        let now = Date()
        scheduleCheck(now.dateAt(schedules[day].times[index].sh, schedules[day].times[index].sm),
                      now.dateAt(schedules[day].times[index].eh, schedules[day].times[index].em),
                      schedules[day].times[index].title)
    }

    func scheduleCheck(_ pcs: Date, _ pce: Date, _ name: String) {
        let now = Date()
        if now >= pcs && now <= pce {
            let minutes = now.minutes(from: pce)*(0-1)
            let seconds = now.seconds(from: pce)*(0-1) - minutes*60
            period.text = name
            timeLeft.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        }
    }

    @IBAction func launchApp(sender: AnyObject) {
        let myAppUrl = URL(string: "venicehigh://bell")!
        extensionContext?.open(myAppUrl, completionHandler: nil)
    }

    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
