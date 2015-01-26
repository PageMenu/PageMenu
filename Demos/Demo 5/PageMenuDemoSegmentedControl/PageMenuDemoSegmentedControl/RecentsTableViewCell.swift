//
//  RecentsTableViewCell.swift
//  PageMenuDemoTabbar
//
//  Created by Niklas Fahl on 1/9/15.
//  Copyright (c) 2015 Niklas Fahl. All rights reserved.
//

import UIKit

class RecentsTableViewCell: UITableViewCell {

    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var activityImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        var path : UIBezierPath = UIBezierPath()
//        path.moveToPoint(CGPointMake(0, 32))
//        path.addLineToPoint(CGPointMake(32, 64))
//        path.addLineToPoint(CGPointMake(64, 32))
//        path.addLineToPoint(CGPointMake(32, 0))
////        path.addLineToPoint(CGPointMake(34, 0))
//        path.closePath()
//        
//        var mask : CAShapeLayer = CAShapeLayer()
//        mask.frame = photoImageView.bounds
//        mask.path = path.CGPath
//        
//        photoImageView.layer.mask = mask
        
        photoImageView.layer.cornerRadius = 15
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
