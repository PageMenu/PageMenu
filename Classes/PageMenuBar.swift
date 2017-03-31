//
//  PageMenuBar.swift
//  PageMenu
//
//  Created by Grayson Webster on 3/31/17.
//  Copyright © 2017 Center for Advanced Public Safety. All rights reserved.
//

import Foundation

open class PageMenuBar: UIToolbar {
    internal var itemContainer: UICollectionView?
    
    open var menuItems: [PageMenuItem]?
    public var selectedItem: PageMenuItem?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Setup Functions
extension PageMenuBar {
    public func setItems(_ items: [PageMenuItem]) {
        self.menuItems = items
    }
}
