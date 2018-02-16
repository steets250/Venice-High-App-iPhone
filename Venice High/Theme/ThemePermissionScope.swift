//
//  ThemePermissionScope.swift
//  Venice High
//
//  Created by Steven Steiner on 2/15/18.
//  Copyright © 2018 Steven Steiner. All rights reserved.
//

import PermissionScope
import UIKit

class ThemePermissionScope: PermissionScope {
    override func viewDidLoad() {
        self.authorizedButtonColor = appDelegate.themeBlue
        self.closeButtonTextColor = appDelegate.themeBlue
        self.permissionButtonTextColor = appDelegate.themeBlue
        self.permissionButtonBorderColor = appDelegate.themeBlue
        if defaults.bool(forKey: "Is Dark") {
            self.permissionLabelColor = .white
            self.permissionViewColor = .black
        } else {
            self.permissionLabelColor = .black
            self.permissionViewColor = .white
        }
    }
}
