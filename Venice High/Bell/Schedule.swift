//
//  Schedule.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper

struct Schedule: Mappable {
    var id: Int = 0
    var file: String = ""
    var title: String = ""

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        file <- map["file"]
        title <- map["title"]
    }
}
