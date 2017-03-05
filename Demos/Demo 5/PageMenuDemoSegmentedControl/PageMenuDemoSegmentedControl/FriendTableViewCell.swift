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
        
        let path : UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 34))
        path.addLine(to: CGPoint(x: 0, y: 64))
        path.addLine(to: CGPoint(x: 64, y: 64))
        path.addLine(to: CGPoint(x: 64, y: 0))
        path.addLine(to: CGPoint(x: 34, y: 0))
        path.close()
        
        let mask : CAShapeLayer = CAShapeLayer()
        mask.frame = photoImageView.bounds
        mask.path = path.cgPath
        
        photoImageView.layer.mask = mask
        
        photoImageView.layer.cornerRadius = 15
        favoriteView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
