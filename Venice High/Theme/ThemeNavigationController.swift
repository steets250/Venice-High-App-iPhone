//
//  ThemeNavigationController.swift
//  Venice High
//
//  Created by Steven Steiner on 2/15/18.
//  Copyright © 2018 Steven Steiner. All rights reserved.
//

import SwiftTheme
import UIKit

class ThemeNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.theme_barTintColor = ThemeColorPicker(keyPath: "Global.barColor")
        self.navigationBar.theme_tintColor = ThemeColorPicker(keyPath: "Global.themeBlue")
        self.navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker(keyPath: "Global.textColor") { value -> [NSAttributedStringKey: AnyObject]? in
            let rgba = value as! String
            return [NSAttributedStringKey.foregroundColor: UIColor(rgba: rgba)]
        }
        self.navigationBar.theme_largeTitleTextAttributes = ThemeDictionaryPicker(keyPath: "Global.textColor") { value -> [NSAttributedStringKey: AnyObject]? in
            let rgba = value as! String
            return [NSAttributedStringKey.foregroundColor: UIColor(rgba: rgba)]
        }
    }
}
