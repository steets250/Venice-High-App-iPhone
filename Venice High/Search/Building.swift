//
//  Building.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper

struct Building: Mappable {
    var name: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        name <- map["name"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
    }
}
