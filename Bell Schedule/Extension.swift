//
//  Extension.swift
//  Bell Schedule
//
//  Created by Steven Steiner on 4/20/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper

struct BellSchedule: Mappable {
    var schedule: String = ""
    var times: [Time] = []

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        schedule <- map["schedule"]
        times    <- map["times"]
    }
}

struct Time: Mappable {
    var id: String = ""
    var sh: Int = 0
    var sm: Int = 0
    var eh: Int = 0
    var em: Int = 0
    var title: String = ""

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id    <- map["id"]
        sh    <- map["sh"]
        sm    <- map["sm"]
        eh    <- map["eh"]
        em    <- map["em"]
        title <- map["title"]
    }
}

struct YMD: Mappable {
    var year: Int = 0; var month: Int = 0; var day: Int = 0; var schedule: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        year     <- map["yy"]
        month    <- map["mm"]
        day      <- map["dd"]
        schedule <- map["s"]
    }
}

extension Date {
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0}

    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0}

    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0}

    func dateAt(_ hours: Int, _ minutes: Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        var date_components = calendar.components(
            [NSCalendar.Unit.year,
             NSCalendar.Unit.month,
             NSCalendar.Unit.day],
            from: self)
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        let newDate = calendar.date(from: date_components)!
        return newDate}

    var weekday: Int {
        return Calendar(identifier: .iso8601).dateComponents([.weekday], from: self).weekday!
    }
}

extension String {
    func getLast(_ count: Int = 1) -> String {
        return substring(from: index(endIndex, offsetBy: -count))
    }
}
