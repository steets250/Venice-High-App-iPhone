//
//  AppData.swift
//  Venice High
//
//  Created by Steven Steiner on 4/4/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import ReachabilitySwift

extension AppDelegate /*App Data Loading*/ {
    func schoolData() {
        if let date = defaults.object(forKey: "refreshData") {
            let dateRefreshed = date as! Date
            let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let components = calendar.components([.day], from: dateRefreshed, to: Date(), options: [])
            if components.day! > 0 {
                if Reachability()!.isReachable {
                    loadFile(false)
                } else {
                    loadData()
                }
            } else {
                loadData()
            }
        } else {
            loadFile(!Reachability()!.isReachable)
        }
    }

    func loadFile(_ manual: Bool = false) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        internet = !manual

        self.loadBuildings(next: {
            self.loadDates(next: {
                self.loadRoom(next: {
                    self.loadStaff(next: {
                        self.processStaff(next: {
                            self.loadTimes(next: {
                                self.saveBell(next: {
                                    self.loadEnding()
                                })
                            })
                        })
                    })
                })
            })
        })
    }

    func loadBuildings(next: (() -> Void)?) {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Buildings.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Buildings", withExtension: "json")!
        }
        Alamofire.request(apiURL).validate().responseArray { (response: DataResponse<[Building]>) in
            switch response.result {
            case .success:
                self.buildingData = response.result.value ?? []
            case .failure(let error):
                print(error)
                self.messedUp = true
            }
            next?()
        }
    }

    func loadDates(next: (() -> Void)?) {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Dates.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Dates", withExtension: "json")!
        }
        Alamofire.request(apiURL).validate().responseArray { (response: DataResponse<[YMD]>) in
            switch response.result {
            case .success:
                self.dateData = response.result.value ?? []
            case .failure(let error):
                print(error)
                self.messedUp = true
            }
            next?()
        }
    }

    func loadRoom(next: (() -> Void)?) {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Rooms.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Rooms", withExtension: "json")!
        }
        Alamofire.request(apiURL).validate().responseArray { (response: DataResponse<[Room]>) in
            switch response.result {
            case .success:
                self.roomData = response.result.value ?? []
            case .failure(let error):
                print(error)
                self.messedUp = true
            }
            next?()
        }
    }

    func loadStaff(next: (() -> Void)?) {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Staff.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Staff", withExtension: "json")!
        }
        Alamofire.request(apiURL).validate().responseArray { (response: DataResponse<[Staff]>) in
            switch response.result {
            case .success:
                self.staffData = response.result.value?.sorted(by: {$0.lastName < $1.lastName}) ?? []
            case .failure(let error):
                print(error)
                self.messedUp = true
            }
            next?()
        }
    }

    func processStaff(next: (() -> Void)?) {
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
        next?()
    }

    func loadTimes(next: (() -> Void)?) {
        var apiURL: URL!
        if internet {
            apiURL = URL(string: baseURL + "Times.json")!
        } else {
            apiURL = Bundle.main.url(forResource: "Times", withExtension: "json")!
        }
        Alamofire.request(apiURL).validate().responseArray { (response: DataResponse<[BellSchedule]>) in
            switch response.result {
            case .success:
                self.timeData = response.result.value ?? []
            case .failure(let error):
                print(error)
                self.messedUp = true
            }
            next?()
        }
    }

    func saveBell(next: (() -> Void)?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if messedUp == false {
            defaults2.set(Mapper().toJSONString(dateData), forKey: "dateData")
            defaults2.set(Mapper().toJSONString(timeData), forKey: "timeData")
        }
        next?()
    }

    func loadEnding() {
        if messedUp || (internet && (buildingData.isEmpty || dateData.isEmpty || roomData.isEmpty || staffData.isEmpty || timeData.isEmpty)) {
            loadFile(false)
        } else if internet && ((!buildingData.isEmpty || !dateData.isEmpty || !roomData.isEmpty || !staffData.isEmpty || !timeData.isEmpty)) {
            saveData()
        }
    }

    func saveData() {
        defaults.set(Date(), forKey: "refreshData")
        defaults.set(Mapper().toJSONString(buildingData), forKey: "buildingData")
        defaults.set(Mapper().toJSONString(dateData), forKey: "dateData")
        defaults.set(Mapper().toJSONString(roomData), forKey: "roomData")
        defaults.set(Mapper().toJSONString(staffData), forKey: "staffData")
        defaults.set(Mapper().toJSONString(timeData), forKey: "timeData")
    }

    func loadData() {
        buildingData = Mapper<Building>().mapArray(JSONString: defaults.string(forKey: "buildingData")!)!
        dateData = Mapper<YMD>().mapArray(JSONString: defaults.string(forKey: "dateData")!)!
        roomData = Mapper<Room>().mapArray(JSONString: defaults.string(forKey: "roomData")!)!
        staffData = Mapper<Staff>().mapArray(JSONString: defaults.string(forKey: "staffData")!)!
        timeData = Mapper<BellSchedule>().mapArray(JSONString: defaults.string(forKey: "timeData")!)!
    }
}
