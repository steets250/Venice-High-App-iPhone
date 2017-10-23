//
//  CreditsViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 3/31/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import MessageUI

class CreditsViewController: UIViewController {
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var collectionOfLabels: Array<UILabel>?
    @IBOutlet var tmLine: UIView!
    @IBOutlet var mbLine: UIView!
    @IBOutlet var emailMe: UIButton!

    var textColor: UIColor!
    var seperatorColor: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "App Credits"

        if defaults.bool(forKey: "Is Dark") {
            self.view.backgroundColor = UIColor(hex: "444444")
            textColor = .white
            seperatorColor = .black
        } else {
            self.view.backgroundColor = UIColor(hex: "BBBBBB")
            textColor = .black
            seperatorColor = .white
        }
        tmLine.backgroundColor = seperatorColor
        mbLine.backgroundColor = seperatorColor
        for label in collectionOfLabels! {
            label.textColor = textColor
            label.adjustsFontSizeToFitWidth = true
        }
        emailMe.setTitleColor(appDelegate.themeBlue, for: .normal)
        self.navigationController?.navigationBar.tintColor = appDelegate.themeBlue
    }

    @IBAction func emailClick(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients(["venicehighapp@gmail.com"])
            self.present(mailComposerVC, animated: true, completion: nil)
        }
    }
}

extension CreditsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
