//
//  AppDelegate.swift
//  Venice High
//
//  Created by Steven Steiner on 2/26/17.
//  Copyright © 2017 steets250. All rights reserved.
//
//

import EventKit
import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var themeBlue: UIColor!
    var schoolStart: Date!
    var schoolEnd: Date!
    let defaults = UserDefaults.standard
    let defaults2 = UserDefaults.init(suiteName: "group.steets250.Venice-High.Bell-Schedule")!

    let baseURL = "https://raw.githubusercontent.com/steets250/Venice-High-App-Data/master/"
    var messedUp = false

    var buildingData = [Building]()
    var dateData = [YMD]()
    var roomData = [Room]()
    var staffData = [Staff]()
    var timeData = [BellSchedule]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let c = NSDateComponents()
        c.year = 2017; c.month = 8; c.day = 15
        schoolStart = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c as DateComponents)!
        c.year = 2017; c.month = 6; c.day = 9
        schoolEnd = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c as DateComponents)!

        UserDefaults.standard.register(defaults: ["Theme Alert": true, "Event Alert": true, "Initial Tab": 0, "Initial Staff": "", "Initial Room": "", "Calendar Name": "", "Calendar Identifier": ""])
        schoolData()
        updateLook()
        sleep(UInt32(1))
        return true
    }

    func updateLook() {
        RegularLabel.appearance().fontName = "HelveticaNeue-Light"
        RegularMarqueeLabel.appearance().fontName = "HelveticaNeue-Light"
        let font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: font!],
                                                               for: .normal)
        var attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.black]
        if (defaults.bool(forKey: "Dark Theme")) {
            defaults.set(true, forKey: "Is Dark")
            themeBlue = UIColor(hex: "007BFF")
            UIApplication.shared.statusBarStyle = .lightContent
            UINavigationBar.appearance().barTintColor = .black
            attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        } else {
            defaults.set(false, forKey: "Is Dark")
            themeBlue = UIColor(hex: "007AFF")
        }
        UINavigationBar.appearance().titleTextAttributes = attributes
        UINavigationBar.appearance().tintColor = themeBlue
    }
}
