//
//  PageMenuItem.swift
//  PageMenu
//
//  Created by Matthew York on 3/9/17.
//  Copyright © 2017 Center for Advanced Public Safety. All rights reserved.
//

import Foundation

public enum PageMenuSystemItem {
    case text
    case image
    case textWithImage
}

public struct PageMenuItem {
    public var titleLabel: UILabel?
    public var selectedTitleLabel: UILabel?
    
    public var image: UIImage?
    public var selectedImage: UIImage?
    
    public var view: UIView?
    public var selectedView: UIView?
    
    public var systemItem: PageMenuSystemItem = .text
    
    // Badge
    public var badgeColor: UIColor?
    public var badgeValue: String?
}

public extension PageMenuItem {
    public func badgeTextAttributes() -> [String: Any]? {
        return nil
    }
    
    public func setBadgeTextAttributes(_ textAttributes: [String: Any]?) {
        
    }
}
