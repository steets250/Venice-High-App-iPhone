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
    var schedule = 1
    var generalTimer: Timer?
    var dates = [YMD]()
    var schedules = [BellSchedule]()
    var error = false
    var schoolStart: Date!
    var schoolEnd: Date!

    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.systemVersion[UIDevice.current.systemVersion.startIndex] == "9" {
            period.textColor = .white; timeLeft.textColor = .white; currentSchedule.textColor = .white
        }
        pageSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        if error {
            error = false
            pageSetup()
        }
    }

    func pageSetup() {
        if defaults.string(forKey: "dateData") != nil {
            dates = Mapper<YMD>().mapArray(JSONString: defaults.string(forKey: "dateData")!)!
        } else {
            error = true
        }
        if defaults.string(forKey: "timeData") != nil {
            schedules = Mapper<BellSchedule>().mapArray(JSONString: defaults.string(forKey: "timeData")!)!
            var new = [BellSchedule]()
            for schedule in schedules {
                new.append(BellSchedule(schedule: schedule.schedule, times: extrasCheck(input: schedule.times)))
            }
            schedules = new
        } else {
            error = true
        }
        if defaults.object(forKey: "schoolStart") != nil {
            schoolStart = defaults.object(forKey: "schoolStart") as! Date
        } else {
            error = true
        }
        if defaults.object(forKey: "schoolEnd") != nil {
            schoolEnd = defaults.object(forKey: "schoolEnd") as! Date
        } else {
            error = true
        }
        if dates.isEmpty || schedules.isEmpty {
            error = true
        }
        if error {
            noData()
        } else {
            initialSchedule()
        }
    }

    func extrasCheck(input: [Time]) -> [Time] {
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
        if defaults.bool(forKey: "Show Period 0") == false {
            let number = times[0].id.getLast()
            times.insert(Time(id: "pp\(number)", sh: 7, sm: 0, eh: 7, em: 57, title: "Passing to Period \(number)"), at: 0)
        }
        return times
    }

    func noData() {
        stackView.removeArrangedSubview(timeLeft)
        timeLeft.textColor = .clear
        period.text = "Error Loading Data"
        currentSchedule.text = "Open App to Refresh"
    }

    func initialSchedule() {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        let year =  components.year; let month = components.month; let day = components.day

        if now.weekday > 1 && now.weekday < 7 && now.isBetween(date: schoolStart, andDate: schoolEnd) {
            for i in dates {
                if (year == i.year && month == i.month && day == i.day) {schedule = i.schedule}
            }
            if schedule == 0 {
                noSchool()
            } else {
                schedule -= 1
                currentSchedule.text = "\(schedules[schedule].schedule) Schedule"
                generalSchedule()
                generalTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.generalSchedule), userInfo: nil, repeats: true)
            }
        } else {
            noSchool()
        }
    }

    func noSchool() {
        stackView.removeArrangedSubview(currentSchedule)
        currentSchedule.textColor = .clear
        stackView.removeArrangedSubview(timeLeft)
        timeLeft.textColor = .clear
        period.text = "No School Today"
    }

    @objc func generalSchedule() {
        let currentTimes = schedules[schedule].times
        notSchool(currentTimes.first!.sh, currentTimes.first!.sm, currentTimes.last!.eh, currentTimes.last!.em)
        for i in 0 ..< currentTimes.count {
            if currentTimes[i].id.getLast() == "0" && defaults.bool(forKey: "Show Period 0") == false {
                continue
            }
            if currentTimes[i].id.getLast() == "7" && defaults.bool(forKey: "Show Period 7") == false {
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
        let pcs = Date().dateAt(schedules[day].times[index].sh, schedules[day].times[index].sm)
        let pce = Date().dateAt(schedules[day].times[index].eh, schedules[day].times[index].em)
        let name = schedules[day].times[index].title

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
