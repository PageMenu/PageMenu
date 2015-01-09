//
//  FriendTableViewCell.swift
//  NFTopMenuController
//
//  Created by Niklas Fahl on 12/17/14.
//  Copyright (c) 2014 Niklas Fahl. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var favoriteView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        var path : UIBezierPath = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 34))
        path.addLineToPoint(CGPointMake(0, 64))
        path.addLineToPoint(CGPointMake(64, 64))
        path.addLineToPoint(CGPointMake(64, 0))
        path.addLineToPoint(CGPointMake(34, 0))
        path.closePath()
        
        var mask : CAShapeLayer = CAShapeLayer()
        mask.frame = photoImageView.bounds
        mask.path = path.CGPath
        
        photoImageView.layer.mask = mask
        
        photoImageView.layer.cornerRadius = 15
        favoriteView.layer.cornerRadius = 15
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
