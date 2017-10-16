//
//  HomeTableViewCell.swift
//  Venice High
//
//  Created by Steven Steiner on 5/11/17.
//  Copyright © 2017 steets250. All rights reserved.
//

import MarqueeLabel
import SwipeCellKit

class TimeTableViewCell: SwipeTableViewCell {
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var timeLabel: UILabel!
}