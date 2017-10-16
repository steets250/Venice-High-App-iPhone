//
//  StaffViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 2/26/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import Spruce
import SwipeCellKit

class StaffViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var segmentedView: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!

    var staffList = [Staff]()
    var currentArray = [Staff]()
    var visibleArray = [Staff]()
    var currentText: String = ""
    var searching: Bool = false

    let animations: [StockAnimation] = [.slide(.left, .severely), .fadeIn]
    var sortFunction: SortFunction = LinearSortFunction(direction: .topToBottom, interObjectDelay: 0.05)

    override func viewDidLoad() {
        super.viewDidLoad()
        darkTheme()
        searchBar.tintColor = appDelegate.themeBlue
        staffList = appDelegate.staffData
        visibleArray = staffList
        tableView.spruce.prepare(with: animations)
        let animation = SpringAnimation(duration: 0.7)
        DispatchQueue.main.async {
            self.tableView.spruce.animate(self.animations, animationType: animation, sortFunction: self.sortFunction)
        }
    }

    func darkTheme() {
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = appDelegate.themeBlue
        if defaults.bool(forKey: "Is Dark") {
            searchBar.backgroundColor = .black
            segmentedView.backgroundColor = .black
            searchBar.backgroundImage = UIImage()
            searchBar.isTranslucent = true
            searchBar.keyboardAppearance = UIKeyboardAppearance.dark
            searchBar.textColor = .white
            tableView.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            self.view.backgroundColor = .black
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

extension StaffViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailView") as! DetailViewController
        popOverVC.type = "Staff"
        popOverVC.staffViaSegue = self.visibleArray[indexPath.row]
        popOverVC.allowButtonsViaSegue = true
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.parent!.parent!.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
}

extension StaffViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if visibleArray.count > 0 {
            self.tableView.backgroundView = .none
            self.tableView.separatorStyle = .singleLine
            return visibleArray.count
        } else {
            EmptyMessage(message: "No staff found.", viewController: self)
            return 0
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
        aCell.titleLabel.text = visibleArray[indexPath.row].lastName + ", " + visibleArray[indexPath.row].firstName
        return aCell
    }

    func EmptyMessage(message: String, viewController: StaffViewController) {
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
}

extension StaffViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searching = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        currentText = ""
        searching = false
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        showSLC()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentText = searchText
        showSLC()
    }

    @IBAction func showComponent(sender: UISegmentedControl) {
        showSLC()
    }

    func showSLC() {
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            currentArray = staffList.filter({$0.alps == true})
        case 2:
            currentArray = staffList.filter({$0.mata == true})
        case 3:
            currentArray = staffList.filter({$0.sma == true})
        case 4:
            currentArray = staffList.filter({$0.stemm == true})
        case 5:
            currentArray = staffList.filter({$0.wlgs == true})
        default:
            currentArray = staffList
        }

        visibleArray = currentArray
        if searching && currentText != "" {
            visibleArray = currentArray.filter { staff in
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
    }
}
