//
//  ThemeTabBarController.swift
//  Venice High
//
//  Created by Steven Steiner on 2/15/18.
//  Copyright © 2018 Steven Steiner. All rights reserved.
//

import SwiftTheme
import UIKit

class ThemeTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.theme_tintColor = ThemeColorPicker(keyPath: "Global.themeGray")
        self.tabBar.theme_barTintColor = ThemeColorPicker(keyPath: "Global.barColor")
    }
}
