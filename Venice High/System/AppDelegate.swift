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
        UserDefaults.standard.register(defaults: ["Theme Alert": true, "Event Alert": true, "Calendar Name": "", "Calendar Identifier": ""])
        schoolData()
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = UITabBarController()
        let calendarViewController = storyboard.instantiateViewController(withIdentifier: "calendarViewController")
        calendarViewController.tabBarItem = UITabBarItem(title: "Calendar", image: #imageLiteral(resourceName: "Calendar"), tag: 0)
        let bellViewController = storyboard.instantiateViewController(withIdentifier: "bellViewController")
        bellViewController.tabBarItem = UITabBarItem(title: "Bell", image: #imageLiteral(resourceName: "Bells"), tag: 1)
        let searchViewController = storyboard.instantiateViewController(withIdentifier: "searchViewController")
        searchViewController.tabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "Search"), tag: 2)
        let infoViewController = storyboard.instantiateViewController(withIdentifier: "infoViewController")
        infoViewController.tabBarItem = UITabBarItem(title: "Info", image: #imageLiteral(resourceName: "Information"), tag: 3)
        let settingsViewController = storyboard.instantiateViewController(withIdentifier: "settingsViewController")
        settingsViewController.tabBarItem = UITabBarItem(title: "Settings", image: #imageLiteral(resourceName: "Settings"), tag: 4)
        tabBarController.viewControllers = [calendarViewController, bellViewController, searchViewController, infoViewController, settingsViewController].map { UINavigationController(rootViewController: $0) }
        window!.rootViewController = tabBarController
        window!.makeKeyAndVisible()
        updateLook()
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
        case openBell = "openBell"
        case openStaff = "openStaff"
        case openRooms = "openRooms"
    }

    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        var quickActionHandled = false
        let type = shortcutItem.type.components(separatedBy: ".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
            let tabBarController = self.window!.rootViewController as! UITabBarController
            switch shortcutType {
            case .openBell:
                tabBarController.selectedIndex = 1
            case .openStaff:
                tabBarController.selectedIndex = 2
                defaults.set(false, forKey: "Room Start")
            case .openRooms:
                tabBarController.selectedIndex = 2
                defaults.set(true, forKey: "Room Start")
            }
            quickActionHandled = true
        }
        return quickActionHandled
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let urlHost: String = url.host as String!
        let tabBarController: UITabBarController = self.window!.rootViewController as! UITabBarController
        switch urlHost {
        case "calendar":
            tabBarController.selectedIndex = 0
        case "bell":
            tabBarController.selectedIndex = 1
        case "search":
            tabBarController.selectedIndex = 2
        case "info":
            tabBarController.selectedIndex = 3
        case "settings":
            tabBarController.selectedIndex = 4
        default:
            tabBarController.selectedIndex = 0
        }
        return true
    }

    func updateLook() {
        RegularLabel.appearance().fontName = "HelveticaNeue-Light"
        RegularMarqueeLabel.appearance().fontName = "HelveticaNeue-Light"
        let font = UIFont(name: "HelveticaNeue-Light", size: 13.0)
        let tabBarController: UITabBarController = self.window!.rootViewController as! UITabBarController
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: font!],
                                                               for: .normal)
        var attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.black]
        if (defaults.bool(forKey: "Dark Theme")) {
            defaults.set(true, forKey: "Is Dark")
            themeBlue = UIColor(hex: "007BFF")
            tabBarController.tabBar.tintColor = .lightGray
            tabBarController.tabBar.barTintColor = .black
            UIApplication.shared.statusBarStyle = .lightContent
            UINavigationBar.appearance().barTintColor = .black
            attributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        } else {
            defaults.set(false, forKey: "Is Dark")
            themeBlue = UIColor(hex: "007AFF")
            tabBarController.tabBar.tintColor = .darkGray
            tabBarController.tabBar.barTintColor = .white
        }
        UINavigationBar.appearance().titleTextAttributes = attributes
        UINavigationBar.appearance().tintColor = themeBlue
    }
}
