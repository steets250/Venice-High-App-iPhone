//
//  ResultsViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 2/15/18.
//  Copyright © 2018 Steven Steiner. All rights reserved.
//

import SwiftTheme
import UIKit

class ResultsViewController: UITableViewController {
    var navController: UINavigationController?

    var staffList = [Staff]()
    var staffVisible = [Staff]()
    var roomList = [Room]()
    var roomVisible = [Room]()
    var currentType = "staff"
    var currentText: String = ""
    var searching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        staffList = appDelegate.staffData
        roomList = appDelegate.roomData
        staffVisible = staffList
        roomVisible = roomList

        tableView.theme_backgroundColor = ThemeColorPicker(keyPath: "Global.backgroundColor")
    }
}

extension ResultsViewController /*TableView Methods*/ {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentType == "staff" {
            if staffVisible.count > 0 {
                self.tableView.backgroundView = .none
                self.tableView.separatorStyle = .singleLine
                return staffVisible.count
            } else {
                emptyMessage(message: "No staff found.", viewController: self)
                return 0
            }
        } else {
            if roomVisible.count > 0 {
                self.tableView.backgroundView = .none
                self.tableView.separatorStyle = .singleLine
                return roomVisible.count
            } else {
                emptyMessage(message: "No room found.", viewController: self)
                return 0
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentType == "staff" {
            let aCell = UITableViewCell()
            aCell.selectionStyle = .none
            aCell.backgroundColor = .clear
            aCell.textLabel!.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
            aCell.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
            if defaults.bool(forKey: "🅱️") {
                let lastname = "🅱️" + String(staffVisible[indexPath.row].lastName.dropFirst())
                let firstname = "🅱️" + String(staffVisible[indexPath.row].firstName.dropFirst())
                aCell.textLabel!.text = lastname + ", " + firstname
            } else {
                let lastname = staffVisible[indexPath.row].lastName
                let firstname = staffVisible[indexPath.row].firstName
                aCell.textLabel!.text = lastname + ", " + firstname
            }
            return aCell
        } else {
            let aCell = UITableViewCell()
            aCell.selectionStyle = .none
            aCell.backgroundColor = .clear
            aCell.textLabel!.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
            aCell.textLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
            aCell.textLabel!.text = roomVisible[indexPath.row].number
            return aCell
        }
    }

    func emptyMessage(message: String, viewController: ResultsViewController) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "System", size: 20)
        messageLabel.sizeToFit()
        viewController.tableView.backgroundView = messageLabel
        viewController.tableView.separatorStyle = .none
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if currentType == "staff" {
            let popOverVC = DetailViewController(type: .staff, staff: self.staffVisible[indexPath.row], room: nil, buttons: true)
            self.navController?.pushViewController(popOverVC, animated: true)
        } else {
            let popOverVC = DetailViewController(type: .room, staff: nil, room: self.roomVisible[indexPath.row], buttons: true)
            self.navController?.pushViewController(popOverVC, animated: true)
        }
    }
}

extension ResultsViewController: UISearchResultsUpdating {
    func updateCurrentType(_ type: String) {
        currentType = type
        refreshData()
    }

    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            currentText = text
            searching = true
            refreshData()
        } else {
            searching = false
            refreshData()
        }
        if currentText == "🅰️" {
            defaults.set(false, forKey: "🅱️")
        }

        if currentText == "🅱️" {
            defaults.set(true, forKey: "🅱️")
        }
        tableView.reloadData()
    }

    func refreshData() {
        if currentType == "staff" {
            staffVisible = staffList
            if searching && currentText != "" {
                staffVisible = staffList.filter { staff in
                    let searchValueIsNotEmpty =
                        staff.firstName.lowercased().contains(currentText.lowercased())
                            || staff.lastName.lowercased().contains(currentText.lowercased())
                            || staff.prefix.lowercased().contains(currentText.lowercased())
                            || String(staff.prefix + staff.lastName).lowercased().contains(currentText.lowercased())
                            || String(staff.prefix.getFirst(2) + staff.lastName).lowercased().contains(currentText.lowercased())
                            || String(staff.prefix + " " + staff.lastName).lowercased().contains(currentText.lowercased())
                            || String(staff.prefix.getFirst(2) + " " + staff.lastName).lowercased().contains(currentText.lowercased())
                    return searchValueIsNotEmpty
                }
            }
            tableView.reloadData()
        } else {
            roomVisible = roomList
            if searching && currentText != "" {
                roomVisible = roomList.filter { room in
                    let searchValueIsNotEmpty =
                        room.number.lowercased().contains(currentText.lowercased())
                            || room.altid.lowercased().contains(currentText.lowercased())
                            || room.building.lowercased().contains(currentText.lowercased())
                    return searchValueIsNotEmpty
                }
            }
            tableView.reloadData()
        }
    }
}
