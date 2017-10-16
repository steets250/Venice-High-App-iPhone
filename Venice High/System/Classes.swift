//
//  Classes.swift
//  Venice High
//
//  Created by Steven Steiner on 9/13/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import MarqueeLabel
import UIKit

class CustomPicker: UIPickerView {
    public var selectorColor: UIColor?
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)

        guard let color = selectorColor else {
            return
        }

        if subview.bounds.height <= 1.0 {
            subview.backgroundColor = color
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard let color = selectorColor else {
            return
        }

        for subview in subviews {
            if subview.bounds.height <= 1.0 {
                subview.backgroundColor = color
            }
        }
    }
}

class RegularLabel: UILabel {
}

class RegularMarqueeLabel: MarqueeLabel {
}
