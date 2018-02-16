//
//  BellSchedule.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper

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
        times <- map["times"]
    }
}
