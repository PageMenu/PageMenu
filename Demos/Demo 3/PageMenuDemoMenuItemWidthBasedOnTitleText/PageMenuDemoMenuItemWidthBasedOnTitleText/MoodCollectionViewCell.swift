//
//  MoodCollectionViewCell.swift
//  NFTopMenuController
//
//  Created by Niklas Fahl on 12/17/14.
//  Copyright (c) 2014 Niklas Fahl. All rights reserved.
//

import UIKit

class MoodCollectionViewCell: UICollectionViewCell {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var moodIconImageView: UIImageView!
    @IBOutlet var moodTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
