//
//  Extensions.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import Reachability
import UIKit

extension UIViewController {
    var defaults: UserDefaults {
        return UserDefaults.standard
    }

    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func internet() -> Bool {
        if Reachability()!.connection != .none {
            return true
        } else {
            return false
        }
    }
}

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    var weekday: Int {
        return Calendar(identifier: .iso8601).dateComponents([.weekday], from: self).weekday!
    }

    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }

    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }

    func dateAt(hours: Int, minutes: Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        var date_components = calendar.components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: self)
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        let newDate = calendar.date(from: date_components)!
        return newDate
    }
}

extension CGRect {
    mutating func offsetInPlace(dx: CGFloat, dy: CGFloat) {
        self = offsetBy(dx: dx, dy: dy)
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(describing: self[substringFrom..<substringTo])
            }
        }
    }

    func getFirst(_ count: Int = 1) -> String {
        return String(describing: self[..<index(startIndex, offsetBy: count)])
    }

    func getLast(_ count: Int = 1) -> String {
        return String(describing: self[index(endIndex, offsetBy: -count)...])
    }
}
