//
//  SearchViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 10/4/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var staffSearch: UIView!
    @IBOutlet weak var roomSearch: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        if defaults.bool(forKey: "Is Dark") {
            self.view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        } else {
            self.view.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
        }
        segmentedControl.tintColor = appDelegate.themeBlue
        roomSearch.alpha = 0.0
        staffSearch.isUserInteractionEnabled = true
        roomSearch.isUserInteractionEnabled = false
        if appDelegate.staffData.isEmpty || appDelegate.roomData.isEmpty {
            appDelegate.loadFile(true)
        }
    }

    func switchPage(index: Int) {
        if index == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.roomSearch.alpha = 0.0
            }, completion: {_ in
                self.staffSearch.isUserInteractionEnabled = true
                self.roomSearch.isUserInteractionEnabled = false
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.roomSearch.alpha = 1.0
            }, completion: {_ in
                self.staffSearch.isUserInteractionEnabled = false
                self.roomSearch.isUserInteractionEnabled = true
            })
        }
    }

    @IBAction func segmentedClick(_ sender: UISegmentedControl) {
        switchPage(index: sender.selectedSegmentIndex)
    }
}
