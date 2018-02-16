//
//  Article.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import ObjectMapper

struct Article {
    var title: String
    var link: String
    var startDate: Date
    var endDate: Date
    var startTime: String
    var endTime: String
    var calendar: Bool?
    var alert: Bool?
}
