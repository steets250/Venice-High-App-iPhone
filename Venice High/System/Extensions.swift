//
//  Extensions.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import Reachability
import UIKit

extension UISearchBar {
    var textColor: UIColor? {
        get {
            if let textField = self.value(forKey: "searchField") as? UITextField {
                return textField.textColor
            } else {
                return nil
            }
        }

        set (newValue) {
            if let textField = self.value(forKey: "searchField") as? UITextField {
                textField.textColor = newValue
            }
        }
    }
}

extension UISegmentedControl {
    func replaceSegments(segments: Array<String>) {
        self.removeAllSegments()
        for segment in segments {
            self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
        }
    }
}

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

    func daysBetweenDates(startDate: Date, endDate: Date) -> Int {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let components = calendar.components([.day], from: startDate, to: endDate, options: [])
        return components.day!

    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension Date {
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0}

    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0}

    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0}

    func dateAt(hours: Int, minutes: Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        var date_components = calendar.components(
            [NSCalendar.Unit.year,
             NSCalendar.Unit.month,
             NSCalendar.Unit.day],
            from: self)
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        let newDate = calendar.date(from: date_components)!
        return newDate}

    var weekday: Int {
        return Calendar(identifier: .iso8601).dateComponents([.weekday], from: self).weekday!}
}

extension UILabel {
    var fontName: String {
        get { return self.font.fontName }
        set { self.font = UIFont(name: newValue, size: self.font.pointSize) }
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
                substring(with: substringFrom..<substringTo)
            }
        }
    }

    func getFirst(_ count: Int = 1) -> String {
        return substring(to: index(startIndex, offsetBy: count))
    }

    func getLast(_ count: Int = 1) -> String {
        return substring(from: index(endIndex, offsetBy: -count))
    }

    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[Range(start ..< end)]
    }
}
