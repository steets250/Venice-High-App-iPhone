//
//  AppData.swift
//  Venice High
//
//  Created by Steven Steiner on 4/4/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper
import Alamofire
import Alamofire_Synchronous
import Reachability

extension AppDelegate /*App Data Loading*/ {
    func schoolData() {
        if defaults.object(forKey: "schoolStart") != nil {
            if Reachability()!.connection == .none {
                loadData()
            } else {
                loadFile(false)
            }
        } else {
            loadFile(Reachability()!.connection == .none)
        }
    }

    func loadFile(_ manual: Bool = false) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        internet = !manual
        loadYear()
        loadBuildings()
        loadDates()
        loadEvents()
        loadRoom()
        loadStaff()
        processStaff()
        loadTimes()
        saveBell()
        loadEnding()
    }

    func loadYear() {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Year.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Year", withExtension: "json")!
        }

        let response = Alamofire.request(apiURL).responseString()
        switch response.result {
        case .success:
            let points = Mapper<Endpoint>().mapArray(JSONString: response.value ?? "") ?? []
            if points.isEmpty == false {
                var c = DateComponents()
                c.year = points[0].year
                c.month = points[0].month
                c.day = points[0].day
                self.schoolStart = Calendar.current.date(from: c)
                c.year = points[1].year
                c.month = points[1].month
                c.day = points[1].day
                self.schoolEnd = Calendar.current.date(from: c)
            } else {
                self.messedUp = true
            }
        case .failure(let error):
            print(error)
            self.messedUp = true
        }
    }

    func loadBuildings() {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Buildings.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Buildings", withExtension: "json")!
        }
        let response = Alamofire.request(apiURL).responseString()
        switch response.result {
        case .success:
            self.buildingData = Mapper<Building>().mapArray(JSONString: response.value ?? "") ?? []
        case .failure(let error):
            print(error)
            self.messedUp = true
        }
    }

    func loadDates() {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Dates.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Dates", withExtension: "json")!
        }
        let response = Alamofire.request(apiURL).responseString()
        switch response.result {
        case .success:
            self.dateData = Mapper<YMD>().mapArray(JSONString: response.value ?? "") ?? []
        case .failure(let error):
            print(error)
            self.messedUp = true
        }
    }

    func loadEvents() {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Events.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Events", withExtension: "json")!
        }
        let response = Alamofire.request(apiURL).responseString()
        switch response.result {
        case .success:
            self.eventData = Mapper<Event>().mapArray(JSONString: response.value ?? "") ?? []
        case .failure(let error):
            print(error)
            self.messedUp = true
        }
    }

    func loadRoom() {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Rooms.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Rooms", withExtension: "json")!
        }
        let response = Alamofire.request(apiURL).responseString()
        switch response.result {
        case .success:
            self.roomData = Mapper<Room>().mapArray(JSONString: response.value ?? "") ?? []
        case .failure(let error):
            print(error)
            self.messedUp = true
        }
    }

    func loadStaff() {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Staff.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Staff", withExtension: "json")!
        }
        let response = Alamofire.request(apiURL).responseString()
        switch response.result {
        case .success:
            self.staffData = Mapper<Staff>().mapArray(JSONString: response.value ?? "") ?? []
            self.staffData = self.staffData.sorted(by: {$0.firstName < $1.firstName})
            self.staffData = self.staffData.sorted(by: {$0.lastName < $1.lastName})
        case .failure(let error):
            print(error)
            self.messedUp = true
        }
    }

    func processStaff() {
        if self.staffData.count > 0 {
            for person in self.staffData {
                if person.p0 != "" {
                    if let i = self.roomData.index(where: {$0.number == person.p0}) {
                        self.roomData[i].teachers.append((period: "p0", teacherId: person.id))
                    }
                }
                if person.p1 != "" {
                    if let i = self.roomData.index(where: {$0.number == person.p1}) {
                        self.roomData[i].teachers.append((period: "p1", teacherId: person.id))
                    }
                }
                if person.p2 != "" {
                    if let i = self.roomData.index(where: {$0.number == person.p2}) {
                        self.roomData[i].teachers.append((period: "p2", teacherId: person.id))
                    }
                }
                if person.p3 != "" {
                    if let i = self.roomData.index(where: {$0.number == person.p3}) {
                        self.roomData[i].teachers.append((period: "p3", teacherId: person.id))
                    }
                }
                if person.p4 != "" {
                    if let i = self.roomData.index(where: {$0.number == person.p4}) {
                        self.roomData[i].teachers.append((period: "p4", teacherId: person.id))
                    }
                }
                if person.p5 != "" {
                    if let i = self.roomData.index(where: {$0.number == person.p5}) {
                        self.roomData[i].teachers.append((period: "p5", teacherId: person.id))
                    }
                }
                if person.p6 != "" {
                    if let i = self.roomData.index(where: {$0.number == person.p6}) {
                        self.roomData[i].teachers.append((period: "p6", teacherId: person.id))
                    }
                }
                if person.p7 != "" {
                    if let i = self.roomData.index(where: {$0.number == person.p7}) {
                        self.roomData[i].teachers.append((period: "p7", teacherId: person.id))
                    }
                }
            }
            for i in 0 ..< self.roomData.count {
                self.roomData[i].teachers = self.roomData[i].teachers.sorted(by: {$0.period.getFirst() < $1.period.getFirst()})
            }
        }
    }

    func loadTimes() {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Times/Schedules.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Schedules", withExtension: "json")!
        }
        let response = Alamofire.request(apiURL).responseString()
        switch response.result {
        case .success:
            let schedules = Mapper<Schedule>().mapArray(JSONString: response.value ?? "") ?? []
            for schedule in schedules {
                loadSchedule(schedule: schedule)
            }
        case .failure(let error):
            print(error)
            self.messedUp = true
        }
    }

    func loadSchedule(schedule: Schedule) {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Times/\(schedule.file).json")!
        } else {
            apiURL = Bundle.main.url(forResource: schedule.file, withExtension: "json")!
        }
        let response = Alamofire.request(apiURL).responseString()
        switch response.result {
        case .success:
            let times = Mapper<Time>().mapArray(JSONString: response.value ?? "") ?? []
            if times.isEmpty == false {
                self.timeData.append(BellSchedule(schedule: schedule.title, times: times))
            } else {
                self.messedUp = true
            }
        case .failure(let error):
            print(error)
            self.messedUp = true
        }
    }

    func saveBell() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if messedUp == false {
            defaults2.set(Mapper().toJSONString(dateData), forKey: "dateData")
            defaults2.set(Mapper().toJSONString(timeData), forKey: "timeData")
            defaults2.set(schoolStart, forKey: "schoolStart")
            defaults2.set(schoolEnd, forKey: "schoolEnd")
        }
    }

    func loadEnding() {
        if messedUp || (internet && (buildingData.isEmpty || dateData.isEmpty || roomData.isEmpty || staffData.isEmpty || timeData.isEmpty)) {
            loadFile(false)
        } else if internet && !buildingData.isEmpty && !dateData.isEmpty && !roomData.isEmpty && !staffData.isEmpty && !timeData.isEmpty {
            saveData()
        }
    }

    func saveData() {
        defaults.set(schoolStart, forKey: "schoolStart")
        defaults.set(schoolEnd, forKey: "schoolEnd")
        defaults.set(Mapper().toJSONString(buildingData), forKey: "buildingData")
        defaults.set(Mapper().toJSONString(dateData), forKey: "dateData")
        defaults.set(Mapper().toJSONString(roomData), forKey: "roomData")
        defaults.set(Mapper().toJSONString(staffData), forKey: "staffData")
        defaults.set(Mapper().toJSONString(timeData), forKey: "timeData")
    }

    func loadData() {
        schoolStart = defaults.object(forKey: "schoolStart") as! Date
        schoolEnd = defaults.object(forKey: "schoolEnd") as! Date
        buildingData = Mapper<Building>().mapArray(JSONString: defaults.string(forKey: "buildingData")!)!
        dateData = Mapper<YMD>().mapArray(JSONString: defaults.string(forKey: "dateData")!)!
        roomData = Mapper<Room>().mapArray(JSONString: defaults.string(forKey: "roomData")!)!
        staffData = Mapper<Staff>().mapArray(JSONString: defaults.string(forKey: "staffData")!)!
        timeData = Mapper<BellSchedule>().mapArray(JSONString: defaults.string(forKey: "timeData")!)!
        processStaff()
    }
}
