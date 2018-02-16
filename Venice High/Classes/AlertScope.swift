//
//  AlertScope.swift
//  Venice High
//
//  Created by Steven Steiner on 5/22/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import PMAlertController
import UIKit

class AlertScope {
    static func showAlert(_ type: HelpPage, _ controller: UIViewController) {
        var titleText: String!
        var paragraphText: String!

        switch type {
        case .eventViewController:
            titleText = "Event Page"
            paragraphText = "View upcoming events at school.\r\n\r\nSwipe from left to right on an event to save it to your calendar or add an alert.\r\n\r\nAlerts will send a notification at the time of the event, or at 7:00 am for all-day events."
        case .visualViewController:
            titleText = "Visual Page"
            paragraphText = "View upcoming events in a calendar format.\r\n\r\nSpecial days are color coded.\r\n\r\nGreen dots are professional development, gray are no school, and yellow are minimum days."
        case .bellViewController:
            titleText = "Bell Page"
            paragraphText = "View all of the current school bell schedule.\r\n\r\nA timer will appear at the top of the page during school hours indicating the time left in the period or passing period.\r\n\r\nSchedules for finals and parent conference days are visible the day they occur."
        case .searchViewController:
            titleText = "Search Page"
            paragraphText = "Find a specific school staff member or room.\r\n\r\nUtilize the search bar for quick results and, for supported devices, 3D press for a preview and shortcuts."
        case .staffViewController:
            titleText = "Detail Page"
            paragraphText = "Send a staff member an email and visit their website.\r\n\r\nRoom schedules are shown for all teachers.\r\n\r\nClick on a room for its location."
        case .roomViewController:
            titleText = "Detail Page"
            paragraphText = "View the location of a room relative to your location with GPS.\r\n\r\nView the staff assigned to a room.\r\n\r\nClick on a staff for their information."
        case .infoViewController:
            titleText = "Info Page"
            paragraphText = "View the website, get directions, and call the school.\r\n\r\nYou can change the app's theme, event calendar, and show/hide periods 0 and 7.\r\n\r\nClick the (i) button in the top right to view app credits."
        }
        var theme: PMAlertThemeStyle!
        if UserDefaults.standard.bool(forKey: "Is Dark") {
            theme = .dark
        } else {
            theme = .default
        }
        let alertController = PMAlertController(title: titleText, message: paragraphText, preferredStyle: .alert, preferredTheme: theme)
        alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.default, handler: nil))
        controller.present(alertController, animated: true, completion: nil)
    }
}

enum HelpPage: String {
    case eventViewController = "eventViewController"
    case visualViewController = "visualViewController"
    case bellViewController = "bellViewController"
    case searchViewController = "searchViewController"
    case staffViewController = "staffViewController"
    case roomViewController = "roomViewController"
    case infoViewController = "infoViewController"
}
