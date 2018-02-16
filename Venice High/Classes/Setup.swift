//
//  Setup.swift
//  Venice High
//
//  Created by Steven Steiner on 2/15/18.
//  Copyright © 2018 Steven Steiner. All rights reserved.
//

import UIKit

class Setup {
    static func page(_ controller: UIViewController, title: String?, leftButton: UIBarButtonItem?, rightButton: UIBarButtonItem?, largeTitle: Bool, back: Bool) {
        controller.navigationItem.title = title
        controller.navigationItem.leftBarButtonItem = leftButton
        controller.navigationItem.rightBarButtonItem = rightButton
        controller.navigationController?.navigationBar.isTranslucent = true
        if #available(iOS 11.0, *) {
            if largeTitle {
                controller.navigationController?.navigationBar.prefersLargeTitles = true
            } else {
                controller.navigationItem.largeTitleDisplayMode = .never
            }
        }
        if back {
            let backButton = UIBarButtonItem()
            backButton.title = "Back"
            controller.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        }
    }
}
