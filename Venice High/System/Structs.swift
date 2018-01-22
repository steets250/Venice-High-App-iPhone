//
//  Structs.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper
import Reachability

struct Article {
    var title: String
    var link: String
    var startDate: Date
    var endDate: Date
    var startTime: String
    var endTime: String
}

struct ArticleGroup {
    var year: Int
    var month: Int
    var articles: [Article]
}

struct Building: Mappable {
    var name: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        name      <- map["name"]
        latitude  <- map["latitude"]
        longitude <- map["longitude"]
    }
}

struct Endpoint: Mappable {
    var name: String = ""
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        name  <- map["name"]
        year  <- map["yy"]
        month <- map["mm"]
        day   <- map["dd"]
    }
}

struct Event: Mappable {
    var title: String = ""
    var link: String = ""
    var startDate: String = ""
    var endDate: String = ""
    var startTime: String = ""
    var endTime: String = ""

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        title  <- map["title"]
        link  <- map["link"]
        startDate  <- map["startDate"]
        endDate  <- map["endDate"]
        startTime  <- map["startTime"]
        endTime  <- map["endTime"]
    }
}

struct Room: Mappable {
    var number: String = ""
    var building: String = ""
    var floor: String = ""
    var altid: String = ""
    var teachers: [(period: String, teacherId: String)] = []

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        number   <- map["number"]
        building <- map["building"]
        floor    <- map["floor"]
        altid    <- map["altid"]
    }
}

struct Staff: Mappable {
    var id: String = ""
    var prefix: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var link: Int = 0
    var mata: Bool = false
    var sma: Bool = false
    var wlgs: Bool = false
    var alps: Bool = false
    var stemm: Bool = false
    var p0: String = ""
    var p1: String = ""
    var p2: String = ""
    var p3: String = ""
    var p4: String = ""
    var p5: String = ""
    var p6: String = ""
    var p7: String = ""

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id        <- map["id"]
        prefix    <- map["prefix"]
        firstName <- map["firstName"]
        lastName  <- map["lastName"]
        email     <- map["email"]
        link      <- map["link"]
        mata      <- map["mata"]
        sma       <- map["sma"]
        wlgs      <- map["wlgs"]
        alps      <- map["alps"]
        stemm     <- map["stemm"]
        p0        <- map["p0"]
        p1        <- map["p1"]
        p2        <- map["p2"]
        p3        <- map["p3"]
        p4        <- map["p4"]
        p5        <- map["p5"]
        p6        <- map["p6"]
        p7        <- map["p7"]
    }
}

struct BellSchedule: Mappable {
    var schedule: String = ""
    var times: [Time] = []

    init(schedule: String, times: [Time]) {
        self.schedule = schedule
        self.times = times
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        schedule <- map["schedule"]
        times    <- map["times"]
    }
}

struct Schedule: Mappable {
    var id: Int = 0
    var file: String = ""
    var title: String = ""

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id    <- map["id"]
        file  <- map["file"]
        title <- map["title"]
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
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    var schedule: Int = 0

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        year     <- map["yy"]
        month    <- map["mm"]
        day      <- map["dd"]
        schedule <- map["s"]
    }
}
