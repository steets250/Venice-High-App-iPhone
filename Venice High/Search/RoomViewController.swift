//
//  RoomViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 2/26/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import Spruce
import SwipeCellKit

class RoomViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var roomList = [Room]()
    var filteredRooms = [Room]()
    var currentArray = [Room]()
    var status: String = "roomList"
    var staffList = [Staff]()

    let animations: [StockAnimation] = [.slide(.left, .severely), .fadeIn]
    var sortFunction: SortFunction = LinearSortFunction(direction: .topToBottom, interObjectDelay: 0.05)

    override func viewDidLoad() {
        super.viewDidLoad()
        roomList = appDelegate.roomData
        staffList = appDelegate.staffData
        updateFilter()
        darkTheme()
        tableView.spruce.prepare(with: animations)
        let animation = SpringAnimation(duration: 0.7)
        DispatchQueue.main.async {
            self.tableView.spruce.animate(self.animations, animationType: animation, sortFunction: self.sortFunction)
        }
    }

    func darkTheme() {
        if defaults.bool(forKey: "Is Dark") {
            searchBar.backgroundColor = .black
            searchBar.backgroundImage = UIImage()
            searchBar.isTranslucent = true
            searchBar.keyboardAppearance = UIKeyboardAppearance.dark
            searchBar.textColor = .white
            tableView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)

            for subView in searchBar.subviews {
                for subViewOne in subView.subviews {
                    if let textField = subViewOne as? UITextField {
                        subViewOne.backgroundColor = .darkGray
                        let textFieldInsideUISearchBarLabel = textField.value(forKey: "placeholderLabel") as? UILabel
                        textFieldInsideUISearchBarLabel?.textColor = .lightGray
                    }
                }
            }
        } else {
            tableView.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
        }
    }
}

extension RoomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailView") as! DetailViewController
        popOverVC.type = "Room"
        popOverVC.roomViaSegue = self.currentArray[indexPath.row]
        popOverVC.allowButtonsViaSegue = true
        tableView.reloadData()
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.parent!.parent!.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
}

extension RoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if status == "filteredRooms" {
            if filteredRooms.count > 0 {
                ClearMessage()
                return filteredRooms.count
            } else {
                EmptyMessage(message: "No rooms found.", viewController: self)
                return 0
            }
        } else {
            ClearMessage()
            return roomList.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchTableViewCell
        aCell.selectionStyle = .none
        aCell.backgroundColor = .clear
        if defaults.bool(forKey: "Is Dark") {
            aCell.titleLabel.textColor = .white
        } else {
            aCell.titleLabel.textColor = .black
        }
        aCell.titleLabel.text = currentArray[indexPath.row].number
        return aCell
    }

    func EmptyMessage(message: String, viewController: RoomViewController) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        messageLabel.text = message
        if defaults.bool(forKey: "Is Dark") {
            messageLabel.textColor = .white
        } else {
            messageLabel.textColor = .black
        }
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "System", size: 20)
        messageLabel.sizeToFit()
        viewController.tableView.backgroundView = messageLabel
        viewController.tableView.separatorStyle = .none
    }

    func ClearMessage() {
        self.tableView.backgroundView = .none
        self.tableView.separatorStyle = .singleLine
    }

    func updateFilter() {
        if searchBar.text != ""{
            currentArray = filteredRooms
            status = "filteredRooms"
        } else {
            currentArray = roomList
            status = "roomList"
        }
    }
}

extension RoomViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        updateFilter()
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredRooms = roomList.filter { room in
            let searchValueIsNotEmpty = (room.number.lowercased().contains(searchText.lowercased()) || room.altid.lowercased().contains(searchText.lowercased()) || room.building.lowercased().contains(searchText.lowercased()))
            return searchValueIsNotEmpty
        }
        updateFilter()
        tableView.reloadData()
    }
}
