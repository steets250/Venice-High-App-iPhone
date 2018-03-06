//
//  AppDelegate.swift
//  Venice High
//
//  Created by Steven Steiner on 2/26/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import EventKit
import PMAlertController
import SwiftTheme
import UIKit
import UserNotifications

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let defaults = UserDefaults.standard
    let defaults2 = UserDefaults.init(suiteName: "group.steets250.Venice-High.Bell-Schedule")!
    var schoolStart: Date!
    var schoolEnd: Date!
    var themeBlue: UIColor!
    var themeAlert: PMAlertThemeStyle! {
        get {
            if UserDefaults.standard.bool(forKey: "Is Dark") {
                return .dark
            } else {
                return .default
            }
        }
    }

    let baseURL = "https://raw.githubusercontent.com/steets250/Venice-High-App-Database/master/"
    var messedUp = false
    var internet: Bool!

    var buildingData = [Building]()
    var dateData = [YMD]()
    var eventData = [Event]()
    var roomData = [Room]()
    var staffData = [Staff]()
    var timeData = [BellSchedule]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if defaults.bool(forKey: "Is Dark") {
           ThemeManager.setTheme(plistName: "Dark", path: .mainBundle)
        } else {
            ThemeManager.setTheme(plistName: "Light", path: .mainBundle)
        }
        
        defaults.set(defaults.bool(forKey: "Queue 🅱️"), forKey: "🅱️")

        schoolData()
        tabSetup()
        updateLook()

        application.applicationIconBadgeNumber = 1
        application.applicationIconBadgeNumber = 0

        UIApplication.shared.isStatusBarHidden = false

        var isLaunchedFromQuickAction = false
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            isLaunchedFromQuickAction = true
            _ = handleQuickAction(shortcutItem)
        }
        return !isLaunchedFromQuickAction
    }

    func tabSetup() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let tabBarController = ThemeTabBarController()

        let calendarViewController = EventViewController()
        calendarViewController.tabBarItem = UITabBarItem(title: "Events", image: UIImage(named: "List"), tag: 0)

        let bellViewController = BellViewController()
        bellViewController.tabBarItem = UITabBarItem(title: "Bell", image: UIImage(named: "Bells"), tag: 1)

        let searchViewController = SearchViewController()
        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "Search"), tag: 2)

        let infoViewController = InfoViewController()
        infoViewController.tabBarItem = UITabBarItem(title: "Info", image: UIImage(named: "Info"), tag: 3)

        tabBarController.viewControllers = [calendarViewController, bellViewController, searchViewController, infoViewController].map { ThemeNavigationController(rootViewController: $0) }

        window!.rootViewController = tabBarController
        window!.makeKeyAndVisible()
    }

    func updateLook() {
        UIApplication.shared.theme_setStatusBarStyle(ThemeStatusBarStylePicker(keyPath: "UISatusBar.statusBarStyle"), animated: true)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 13.0)!], for: .normal)
        if defaults.bool(forKey: "Is Dark") {
            themeBlue = UIColor(red:0.20, green:0.59, blue:1.00, alpha:1.0)
        } else {
            themeBlue = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        }
    }
}

extension AppDelegate /*External Launch*/ {
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }

    enum Shortcut: String {
        case openEvents = "openEvents"
        case openBell = "openBell"
        case openSearch = "openSearch"
        case openInfo = "openInfo"
    }

    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        var quickActionHandled = false
        let type = shortcutItem.type.components(separatedBy: ".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
            let tabBarController = self.window!.rootViewController as! UITabBarController
            switch shortcutType {
            case .openEvents:
                tabBarController.selectedIndex = 0
            case .openBell:
                tabBarController.selectedIndex = 1
            case .openSearch:
                tabBarController.selectedIndex = 2
            case .openInfo:
                tabBarController.selectedIndex = 3
            }
            quickActionHandled = true
        }
        return quickActionHandled
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let tabBarController: UITabBarController = self.window!.rootViewController as! UITabBarController
        let urlHost = url.host ?? ""
        switch urlHost {
        case "events":
            tabBarController.selectedIndex = 0
        case "bell":
            tabBarController.selectedIndex = 1
        case "search":
            tabBarController.selectedIndex = 2
        case "info":
            tabBarController.selectedIndex = 3
        default:
            tabBarController.selectedIndex = 0
        }
        return true
    }
}
