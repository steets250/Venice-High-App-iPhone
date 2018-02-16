//
//  Staff.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper

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
        id <- map["id"]
        prefix <- map["prefix"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        email <- map["email"]
        link <- map["link"]
        mata <- map["mata"]
        sma <- map["sma"]
        wlgs <- map["wlgs"]
        alps <- map["alps"]
        stemm <- map["stemm"]
        p0 <- map["p0"]
        p1 <- map["p1"]
        p2 <- map["p2"]
        p3 <- map["p3"]
        p4 <- map["p4"]
        p5 <- map["p5"]
        p6 <- map["p6"]
        p7 <- map["p7"]
    }
}
