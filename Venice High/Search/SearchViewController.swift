//
//  SearchViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 2/26/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import MessageUI
import PermissionScope
import PMAlertController
import Spruce
import SwiftMapVC
import SwiftTheme
import SwiftWebVC
import SwipeCellKit

class SearchViewController: UITableViewController {
    var segmentedControl: UISegmentedControl!
    var searchController: UISearchController!
    var resultsController: ResultsViewController!
    var searchBar: UISearchBar!

    var staffList = [Staff]()
    var staffVisible = [Staff]()
    var roomList = [Room]()
    var roomVisible = [Room]()
    var currentType: DetailViewType = .staff
    var currentText: String = ""
    var searching: Bool = false
    let animations: [StockAnimation] = [.slide(.left, .severely), .fadeIn]
    var sortFunction: SortFunction = LinearSortFunction(direction: .topToBottom, interObjectDelay: 0.05)

    override func viewDidLoad() {
        super.viewDidLoad()

        Setup.page(self, title: "Staff List", leftButton: UIBarButtonItem(image: UIImage(named: "Help"), style: .plain, target: self, action: #selector(openHelp)), rightButton: nil, largeTitle: true, back: true)

        pageSetup()
        visualSetup()

        staffList = appDelegate.staffData
        roomList = appDelegate.roomData
        staffVisible = staffList
        roomVisible = roomList

        definesPresentationContext = true

        tableView.spruce.prepare(with: animations)
        let animation = SpringAnimation(duration: 0.7)
        DispatchQueue.main.async {
            self.tableView.spruce.animate(self.animations, animationType: animation, sortFunction: self.sortFunction)
        }

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if #available(iOS 11.0, *) {
            searchController.isActive = false
        } else {
            searchBar.text = nil
            currentText = ""
            searching = false
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.endEditing(true)
            refreshData()
        }
    }

    func pageSetup() {
        segmentedControl = UISegmentedControl(items: ["Staff", "Rooms"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(self.changeType), for: .valueChanged)
        segmentedControl.theme_tintColor = ThemeColorPicker(keyPath: "Global.themeBlue")
        self.navigationItem.titleView = segmentedControl

        resultsController = ResultsViewController()
        resultsController.navController = navigationController
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = resultsController
        searchController.searchBar.placeholder = "Search Staff"

        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        searchBar.placeholder = "Search Staff"
        searchBar.delegate = self

        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.searchController = searchController
        } else {
            self.tableView.tableHeaderView = searchBar
        }
    }

    func visualSetup() {
        tableView.theme_backgroundColor = ThemeColorPicker(keyPath: "Global.backgroundColor")
        searchController.searchBar.theme_keyboardAppearance = ThemeKeyboardAppearancePicker(keyPath: "UISearchBar.keyboardAppearance")
        searchController.searchBar.theme_barStyle = ThemeBarStylePicker(keyPath: "UISearchBar.barStyle")
        let textFieldInsideSearchController = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchController?.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")

        searchBar.theme_keyboardAppearance = ThemeKeyboardAppearancePicker(keyPath: "UISearchBar.keyboardAppearance")
        searchBar.theme_barStyle = ThemeBarStylePicker(keyPath: "UISearchBar.barStyle")
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.theme_textColor = ThemeColorPicker(keyPath: "Global.textColor")
    }

    @objc func changeType() {
        if segmentedControl.selectedSegmentIndex == 0 {
            currentType = .staff
            self.navigationItem.title = "Staff List"
            searchBar.placeholder = "Search Staff"
            searchController.searchBar.placeholder = "Search Staff"
            resultsController.updateCurrentType(.staff)
        }
        if segmentedControl.selectedSegmentIndex == 1 {
            currentType = .room
            self.navigationItem.title = "Room List"
            searchBar.placeholder = "Search Rooms"
            searchController.searchBar.placeholder = "Search Rooms"
            resultsController.updateCurrentType(.room)
        }
        refreshData()
    }

    @objc func openHelp() {
        AlertScope.showAlert(.searchViewController, self)
    }
}

extension SearchViewController /*TableView Methods*/ {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentType == .staff {
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
        if currentType == .staff {
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

    func emptyMessage(message: String, viewController: SearchViewController) {
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
        if currentType == .staff {
            let popOverVC = DetailViewController(type: .staff, staff: self.staffVisible[indexPath.row], room: nil, buttons: true)
            self.navigationController!.pushViewController(popOverVC, animated: true)
        } else {
            let popOverVC = DetailViewController(type: .room, staff: nil, room: self.roomVisible[indexPath.row], buttons: true)
            self.navigationController!.pushViewController(popOverVC, animated: true)
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
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
            defaults.set(false, forKey: "Queue 🅱️")
        }
        
        if currentText == "🅱️" {
            defaults.set(true, forKey: "Queue 🅱️")
        }
        self.tableView.reloadData()
    }

    func refreshData() {
        if currentType == .staff {
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

extension SearchViewController: UISearchBarDelegate {
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
        refreshData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "🅱️" {
            defaults.set(!(defaults.bool(forKey: "🅱️")), forKey: "🅱️")
        }
        searchBar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentText = searchText
        refreshData()
    }
}

extension SearchViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let indexPath = tableView.indexPathForRow(at: location)!
        let cell = tableView.cellForRow(at: indexPath)!
        var popOverVC: DetailViewController!
        if currentType == .staff {
            popOverVC = DetailViewController(type: .staff, staff: self.staffVisible[indexPath.row], room: nil, buttons: true)
        } else {
            popOverVC = DetailViewController(type: .room, staff: nil, room: self.roomVisible[indexPath.row], buttons: true)
        }
        previewingContext.sourceRect = cell.frame
        popOverVC.emailShortcut = {
            self.emailAction(email: popOverVC.staffViaSegue.email)
        }
        popOverVC.locationShortcut = {
            self.buildingAction(room: popOverVC.roomViaSegue)
        }
        popOverVC.websiteShortcut = {
            self.websiteAction(link: popOverVC.staffViaSegue.link)
        }
        return popOverVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController!.pushViewController(viewControllerToCommit, animated: true)
    }
}

extension SearchViewController /*Preview Actions*/ {
    func websiteAction(link: Int) {
        if internet() {
            let url = "https://venicehs-lausd-ca.schoolloop.com/cms/user?d=x&group_id=" + String(link)
            if defaults.bool(forKey: "Is Dark") {
                let webVC = SwiftModalWebVC(urlString: url, theme: .dark, dismissButtonStyle: .arrow)
                present(webVC, animated: true, completion: nil)
            } else {
                let webVC = SwiftModalWebVC(urlString: url)
                present(webVC, animated: true, completion: nil)
            }
        } else {
            let alertController = PMAlertController(title: "No Network", message: "Please connect your phone to a wifi or cellular network.", preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
            alertController.addAction(PMAlertAction(title: "OK", style: PMAlertActionStyle.default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }

    func emailAction(email: String) {
        let alertController = PMAlertController(title: "Email", message: email, preferredStyle: .alert, preferredTheme: appDelegate.themeAlert)
        alertController.addAction(PMAlertAction(title: "Copy to Clipboard", style: PMAlertActionStyle.default, handler: {
            UIPasteboard.general.string = email
        }))
        if MFMailComposeViewController.canSendMail() {
            alertController.addAction(PMAlertAction(title: "Send Email", style: PMAlertActionStyle.default, handler: {
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self
                mailComposerVC.setToRecipients([email])
                self.present(mailComposerVC, animated: true, completion: nil)
            }))
        }
        alertController.addAction(PMAlertAction(title: "Dismiss", style: PMAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func buildingAction(room: Room) {
        switch ThemePermissionScope().statusLocationInUse() {
        case .unknown, .authorized:
            let pscope = ThemePermissionScope()
            pscope.addPermission(LocationWhileInUsePermission(),
                                 message: "Shows you how to get\r\nto a building.")
            pscope.show({ _, _ in
                self.openMap(room: room)
            }, cancelled: { (_) -> Void in
                self.openMap(room: room)
            })
        case .unauthorized, .disabled:
            openMap(room: room)
            return
        }
    }

    func openMap(room: Room) {
        var longitude: Double!
        var latitude: Double!
        if let building = appDelegate.buildingData.filter({ $0.name == room.building }).first {
            longitude = building.longitude
            latitude = building.latitude
        }
        var mapVC: SwiftModalMapVC!
        if defaults.bool(forKey: "Is Dark") {
            if room.altid == "" {
                mapVC = SwiftModalMapVC(room: room.number, building: room.building, floor: room.floor, latitude: latitude, longitude: longitude, theme: .dark)
            } else {
                mapVC = SwiftModalMapVC(room: room.altid, building: room.building, floor: room.floor, latitude: latitude, longitude: longitude, theme: .dark)
            }

        } else {
            if room.altid == "" {
                mapVC = SwiftModalMapVC(room: room.number, building: room.building, floor: room.floor, latitude: latitude, longitude: longitude, theme: .dark)
            } else {
                mapVC = SwiftModalMapVC(room: room.altid, building: room.building, floor: room.floor, latitude: latitude, longitude: longitude, theme: .dark)
            }
        }
        self.present(mapVC, animated: true, completion: nil)
    }
}

extension SearchViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
