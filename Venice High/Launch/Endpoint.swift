//
//  Endpoint.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper

struct Endpoint: Mappable {
    var name: String = ""
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        name <- map["name"]
        year <- map["yy"]
        month <- map["mm"]
        day <- map["dd"]
    }
}
