//
//  Sundown.swift
//  Venice High
//
//  Created by Steven Steiner on 3/27/18.
//  Copyright © 2018 Steven Steiner. All rights reserved.
//

import MapKit
import Solar

class Sundown {
    static func isDark(date: Date = Calendar.current.date(byAdding: .second, value: TimeZone.current.secondsFromGMT(), to: Date())!, coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 33.997058, longitude: -118.445751)) -> Bool {
        let solar = Solar(for: date, coordinate: coordinate)
        let sunrise = Calendar.current.date(byAdding: .second, value: TimeZone.current.secondsFromGMT(), to: solar!.sunrise!)!
        let now = Calendar.current.date(byAdding: .second, value: TimeZone.current.secondsFromGMT(), to: Date())!
        let sunset = Calendar.current.date(byAdding: .second, value: TimeZone.current.secondsFromGMT(), to: solar!.sunset!)!
        if now > sunrise && now < sunset {
            return false
        } else {
            return true
        }
    }
}
