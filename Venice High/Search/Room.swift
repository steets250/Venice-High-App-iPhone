//
//  Room.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper

struct Room: Mappable {
    var number: String = ""
    var building: String = ""
    var floor: Int = 0
    var altid: String = ""
    var teachers: [(period: String, teacherId: String)] = []

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        number <- map["number"]
        building <- map["building"]
        floor <- map["floor"]
        altid <- map["altid"]
    }
}
