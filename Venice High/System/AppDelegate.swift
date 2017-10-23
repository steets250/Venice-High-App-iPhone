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
    var internet: Bool!

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
        UserDefaults.standard.register(defaults: ["Theme Alert": true, "Event Alert": true, "Initial Tab": 0, "Calendar Name": "", "Calendar Identifier": ""])
        updateLook()
        if UserDefaults.standard.bool(forKey: "Cleared Old") == false {
            UserDefaults.standard.removeObject(forKey: "Last Refreshed")
            UserDefaults.standard.removeObject(forKey: "refreshData")
            UserDefaults.standard.set(true, forKey: "Cleared Old")
        }
        schoolData()
        var isLaunchedFromQuickAction = false
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            isLaunchedFromQuickAction = true
            _ = handleQuickAction(shortcutItem)
        }
        return !isLaunchedFromQuickAction
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }

    enum Shortcut: String {
        case openCalendar = "openCalendar"
        case openBell = "openBell"
        case openSearch = "openSearch"
        case openInfo = "openInfo"
        case openSettings = "openSettings"
    }

    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        var quickActionHandled = false
        let type = shortcutItem.type.components(separatedBy: ".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
            switch shortcutType {
            case .openCalendar:
                defaults.set(0, forKey: "Initial Tab")
            case .openBell:
                defaults.set(1, forKey: "Initial Tab")
            case .openSearch:
                defaults.set(2, forKey: "Initial Tab")
            case .openInfo:
                defaults.set(3, forKey: "Initial Tab")
            case .openSettings:
                defaults.set(4, forKey: "Initial Tab")
            }
            quickActionHandled = true
        }
        return quickActionHandled
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let urlHost: String = url.host as String!

        switch urlHost {
        case "calendar":
            defaults.set(0, forKey: "Initial Tab")
        case "bell":
            defaults.set(1, forKey: "Initial Tab")
        case "search":
            defaults.set(2, forKey: "Initial Tab")
        case "info":
            defaults.set(3, forKey: "Initial Tab")
        case "settings":
            defaults.set(4, forKey: "Initial Tab")
        default:
            defaults.set(0, forKey: "Initial Tab")
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootController = storyboard.instantiateViewController(withIdentifier: "Tab_Page") as! TabController
        if let window = self.window {
            window.rootViewController = rootController
        }
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
