//
//  SearchViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 10/4/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import SAConfettiView

class SearchViewController: ConfettiViewController {
    @IBOutlet weak var staffSearch: UIView!
    @IBOutlet weak var roomSearch: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        iconType = "Search"
        if defaults.bool(forKey: "Is Dark") {
            self.view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        } else {
            self.view.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
        }
        if appDelegate.staffData.isEmpty || appDelegate.roomData.isEmpty {
            appDelegate.loadFile(true)
        }
        openStaff()
    }

    func openStaff() {
        self.navigationItem.title = "Staff"
        UIView.animate(withDuration: 0.25, animations: {
            self.roomSearch.alpha = 0.0
        }, completion: {_ in
            self.staffSearch.isUserInteractionEnabled = true
            self.roomSearch.isUserInteractionEnabled = false
        })
        self.navigationItem.setLeftBarButton(nil, animated: true)
        let rightButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Room"), style: .plain, target: self, action: #selector(openRooms))
        self.navigationItem.setRightBarButton(rightButtonItem, animated: true)
    }

    func openRooms() {
        self.navigationItem.title = "Rooms"
        UIView.animate(withDuration: 0.25, animations: {
            self.roomSearch.alpha = 1.0
        }, completion: {_ in
            self.staffSearch.isUserInteractionEnabled = false
            self.roomSearch.isUserInteractionEnabled = true
        })
        self.navigationItem.setRightBarButton(nil, animated: true)
        let leftButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Staff"), style: .plain, target: self, action: #selector(openStaff))
        self.navigationItem.leftBarButtonItem = leftButtonItem
    }
}
