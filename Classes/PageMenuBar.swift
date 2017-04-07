//
//  PageMenuBar.swift
//  PageMenu
//
//  Created by Grayson Webster on 3/31/17.
//  Copyright © 2017 Center for Advanced Public Safety. All rights reserved.
//

import Foundation

public enum Alignment {
    case left
    case centered
    case right
}
open class PageMenuBar: UIToolbar {
    //internal var itemContainer: UICollectionView?
    
    // MARK: - Properties
    var reuseIdentifier = "MenuCell"
    open var controller: PageMenuController?
    open var spacing: CGFloat = 22.0
    open var alignment: Alignment = .centered
    open var buttonItems: [UIButton] = []
    open var selectedItem: UIButton?
    open var collectionView: UICollectionView?
    open var cellSpacing: CGFloat = 1.0
    
    public init(frame: CGRect, controller: PageMenuController) {
        super.init(frame: frame)
        self.controller = controller
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView!)
        collectionView!.dataSource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Setup Functions
extension PageMenuBar {
    
    // MARK: Add/Remove Items
    public func addItem(title: String, at: Int) {
        let button = UIButton(frame: CGRect(x:0, y:0, width: 40.0, height: 60.0))
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(scrollToPage), for: .touchUpInside)
        buttonItems.insert(button, at: at)
        collectionView?.reloadData()
    }
    
    public func addItem(image: UIImage, at: Int) {
        let button = UIButton(frame: CGRect(x:0, y:0, width: 40.0, height: 60.0))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(scrollToPage), for: .touchUpInside)
        buttonItems.insert(button, at: at)
        collectionView?.reloadData()
    }
    
    public func removeItem(at: Int) {
        buttonItems.remove(at: at)
        collectionView?.reloadData()
    }
    
    
    // MARK: Spacing and Alignment of Buttons
//
//    public func setItemSpacing(spacing: CGFloat) {
//        self.spacing = spacing
//        updateItems()
//    }
//    
//    public func setAlignment(alignment: Alignment) {
//        clearItems()
//        if alignment == .left {
//            setMenuWithSpacing()
//        }
//        else if alignment == .centered {
//            setMenuWithSpacing()
//        }
//        else {
//            setMenuWithSpacing()
//        }
//    }
    
    // MARK: Helpers
    func scrollToPage(sender: UIButton) {
        let index = buttonItems.index(of: sender)
        let indexPath = IndexPath(item: 0, section: index!)
        controller?.scrollToPage(indexPath)
    }
    
    func getTotalCellWidth() -> CGFloat {
        var totalWidth: CGFloat = 0
        for item in buttonItems {
            totalWidth += item.frame.width
        }
        return totalWidth
    }
    
}

// MARK: - Private
extension PageMenuBar {
    func itemForIndexPath(_ indexPath: IndexPath) -> UIButton {
        return buttonItems[(indexPath as NSIndexPath).item]
    }
}


// MARK: - UICollectionViewDataSource
extension PageMenuBar: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as UICollectionViewCell
        cell.contentView.addSubview(itemForIndexPath(indexPath))
        return cell
    }
    
    // Cell size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: itemForIndexPath(indexPath as IndexPath).frame.width, height: self.frame.height)
    }
    
    // Interspacing
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return cellSpacing
    }
    
    // Alignment
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = getTotalCellWidth()
        let totalSpacingWidth = cellSpacing * (CGFloat(buttonItems.count) - 1)
        
        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
    }
    
}
