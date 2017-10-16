//
//  TabController.swift
//  Venice High
//
//  Created by Steven Steiner on 4/7/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import MiniTabBar

class TabController: UITabBarController, MiniTabBarDelegate {
    var currentTab = -1
    var miniBar = MiniTabBar(items: [MiniTabBarItem(title: "Calendar", icon: #imageLiteral(resourceName: "Calendar")),
                                     MiniTabBarItem(title: "Bell", icon: #imageLiteral(resourceName: "Bells")),
                                     MiniTabBarItem(title: "Search", icon: #imageLiteral(resourceName: "Search")),
                                     MiniTabBarItem(title: "Info", icon: #imageLiteral(resourceName: "Information")),
                                     MiniTabBarItem(title: "Settings", icon: #imageLiteral(resourceName: "Settings"))])

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isHidden = true
        if defaults.bool(forKey: "Is Dark") {
            miniBar.tintColor = .lightGray
            miniBar.backgroundColor = .black
        } else {
            miniBar.tintColor = .darkGray
            miniBar.backgroundColor = .white
        }
        miniBar.backgroundBlurEnabled = false
        miniBar.keyLine.isHidden = true
        miniBar.delegate = self
        miniBar.frame = self.tabBar.frame
        self.view.addSubview(miniBar)
        miniBar.selectItem(defaults.integer(forKey: "Initial Tab"), animated: false)
        defaults.set(0, forKey: "Initial Tab")
    }

    func tabSelected(_ index: Int) {
        self.selectedIndex = index
    }
}
