//
//  ConfettiViewController.swift
//  Venice High
//
//  Created by Steven Steiner on 9/8/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import SAConfettiView

class ConfettiViewController: UIViewController {
    var confettiView: SAConfettiView!
    var recognizer: UITapGestureRecognizer!
    var iconType: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        recognizer = UITapGestureRecognizer(target: self, action: #selector(self.startConfetti))
        recognizer.numberOfTapsRequired = 2
        recognizer.numberOfTouchesRequired = 1
        self.navigationController?.navigationBar.addGestureRecognizer(recognizer)
    }

    func startConfetti() {
        if (self.navigationController?.viewControllers.count == 1) {
            confettiView = SAConfettiView(frame: self.parent!.parent!.view.frame)
            confettiView.colors = [.purple, .blue, .green, .yellow, .orange, .red]
            confettiView.type = iconType
            self.parent!.parent!.view.addSubview(confettiView)
            recognizer.isEnabled = false
            confettiView.startConfetti()
            _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.stopConfetti), userInfo: nil, repeats: false)
        }
    }

    func stopConfetti() {
        confettiView.stopConfetti()
        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.removeConfetti), userInfo: nil, repeats: false)
    }

    func removeConfetti() {
        UIView.animate(withDuration: 0.5, animations: {self.confettiView.alpha = 0.0},
                       completion: {(_: Bool) in
                        self.confettiView.removeFromSuperview()
                        self.confettiView = nil
                        self.recognizer.isEnabled = true
        })
    }
}
