//
//  InformationViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 2/26/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import RFAboutView_Swift
import SwiftWebVC

class InformationViewController: UIViewController {
    @IBOutlet weak var schoolTitle: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var website: UIButton!
    @IBOutlet weak var address: UIButton!
    @IBOutlet weak var phone: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.bool(forKey: "Is Dark") {
            self.view.backgroundColor = .black
            schoolTitle.textColor = .white
        } else {
            self.view.backgroundColor = .white
            schoolTitle.textColor = .black
        }
        infoButton.tintColor = appDelegate.themeBlue
    }

    @IBAction func telephone(_ sender: UIButton) {
        let alertController = UIAlertController(title: "(310) 577-4200", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Copy to Clipboard", style: UIAlertActionStyle.default, handler: {_ in
            UIPasteboard.general.string = "3105774200"
        }))
        alertController.addAction(UIAlertAction(title: "Call", style: UIAlertActionStyle.default, handler: {_ in
            UIApplication.shared.openURL(URL(string: "tel://3105774200")!)
        }))
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func address(_ sender: UIButton) {
        let alertController = UIAlertController(title: "13000 Venice Blvd.\nLos Angeles, CA 90066", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Copy to Clipboard", style: UIAlertActionStyle.default, handler: {_ in
            UIPasteboard.general.string = "13000 Venice Blvd., Los Angeles, CA 90066"
        }))
        alertController.addAction(UIAlertAction(title: "Get Directions", style: UIAlertActionStyle.default, handler: {_ in
            UIApplication.shared.openURL(URL(string: "http://maps.apple.com/?q=" + "13000 Venice Blvd. 90066".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!)
        }))
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func website(_ sender: UIButton) {
        if internet() {
            let url = "https://venicehs-lausd-ca.schoolloop.com/"
            if defaults.bool(forKey: "Is Dark") {
                let webVC = SwiftModalWebVC(urlString: url, theme: .dark, dismissButtonStyle: .arrow)
                self.present(webVC, animated: true, completion: nil)
            } else {
                let webVC = SwiftModalWebVC(urlString: url)
                self.present(webVC, animated: true, completion: nil)
            }
        } else {
            let alertController = UIAlertController(title: "No Network", message: "Please connect your phone to a wifi or cellular network.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func information(_ sender: Any) {
        let aboutView = RFAboutViewController(copyrightHolderName: "Steven Steiner", contactEmail: "venicehighapp@gmail.com", contactEmailTitle: "App Feedback", websiteURL: URL(string: "http://venicehigh.steets250.com"), websiteURLTitle: "App Website")
        aboutView.buttonTintColor = appDelegate.themeBlue

        if defaults.bool(forKey: "Is Dark") {
            aboutView.blurAlpha = 0.75
            aboutView.tintColor = .white
            aboutView.buttonTintColor = .white
            aboutView.backgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1)
            aboutView.headerTextColor = .white
            aboutView.headerBorderColor = .darkGray
            aboutView.headerBackgroundColor = .black
            aboutView.acknowledgementsHeaderColor = .white
            aboutView.tableViewBackgroundColor = .black
            aboutView.tableViewTextColor = .white
            aboutView.blurColor = .black
            aboutView.tableViewSeparatorColor = UIColor.white.withAlphaComponent(0.5)
            aboutView.tableViewSelectionColor = .darkGray
        }

        aboutView.headerBackgroundImage = #imageLiteral(resourceName: "Acknowledgements")

        self.navigationController?.pushViewController(aboutView, animated: true)
    }
}
