//
//  Time.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper

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
        id <- map["id"]
        sh <- map["sh"]
        sm <- map["sm"]
        eh <- map["eh"]
        em <- map["em"]
        title <- map["title"]
    }
}
