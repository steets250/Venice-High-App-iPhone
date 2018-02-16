//
//  Event.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper

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
        title <- map["title"]
        link <- map["link"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
    }
}
