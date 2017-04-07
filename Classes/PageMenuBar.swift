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
    case middle // Center the middle menu item (or middle two if there is an even number of items).
    case fit
    case none
}
open class PageMenuBar: UIToolbar {
    //internal var itemContainer: UICollectionView?
    
    // MARK: - Properties
    var reuseIdentifier = "MenuCell"
    
    // Main properties
    open var controller: PageMenuController?
    open var collectionView: UICollectionView?
    open var buttonItems: [UIButton] = []
    public private(set) var selectedItem: UIButton?
    
    // Customization properties
    public fileprivate(set) var alignment: Alignment = .left
    public fileprivate(set) var interspacing: CGFloat = 10.0
    public fileprivate(set) var topSpacing: CGFloat = 6.0
    public fileprivate(set) var leftSpacing: CGFloat = 6.0
    public fileprivate(set) var bottomSpacing: CGFloat = 0
    public fileprivate(set) var rightSpacing: CGFloat = 6.0
    
    // Alignment calculated property
    fileprivate var alignmentLeftSpacing: CGFloat = 0
    
    // Menu overflow properties
    open var overflowLeftSpacing: CGFloat = 6.0
    open var overflowRightSpacing: CGFloat = 6.0
    fileprivate var scrolledOnOverflow = false
    fileprivate var overflow = false
    
    public init(frame: CGRect, controller: PageMenuController) {
        super.init(frame: frame)
        self.controller = controller
        setupCollectionView()
        adjustAlignment()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView!)
        collectionView!.dataSource = self
        collectionView!.delegate = self
    }
    
}

// MARK: - Setup Functions
extension PageMenuBar {
    
    // MARK: Add/Remove Items
    public func addItem(title: String, at: Int) {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(scrollToPage), for: .touchUpInside)
        buttonItems.insert(button, at: at)
        adjustAlignment()
    }
    
    public func addItem(image: UIImage, at: Int) {
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(scrollToPage), for: .touchUpInside)
        buttonItems.insert(button, at: at)
        adjustAlignment()
    }
    
    public func removeItem(at: Int) {
        buttonItems.remove(at: at)
        adjustAlignment()
    }
    
    // MARK: Alignment (changes spacing variables)
    public func setAlignment(alignment: Alignment) {
        self.overflow = false
        self.scrolledOnOverflow = false
        self.alignment = alignment
        if alignment == .left {
            if getTotalSpacingWidth() + getTotalItemWidth() > self.frame.width {
                self.overflow = true
            } else {
                alignmentLeftSpacing = 0
            }
        } else if alignment == .centered {
            if getTotalSpacingWidth() + getTotalItemWidth() > self.frame.width {
                self.overflow = true
            } else {
                alignmentLeftSpacing = (self.frame.width - getTotalItemWidth() - getTotalSpacingWidth()) / 2 - rightSpacing
            }
        } else if alignment == .right {
            if getTotalSpacingWidth() + getTotalItemWidth() > self.frame.width {
                self.overflow = true
            } else {
                alignmentLeftSpacing = self.frame.width - getTotalItemWidth() - getTotalSpacingWidth() - leftSpacing - rightSpacing
            }
        } else if alignment == .middle {
            if getTotalSpacingWidth() + getTotalItemWidth() > self.frame.width {
                self.overflow = true
            } else {
                if buttonItems.count % 2 == 0 {
                    alignmentLeftSpacing = (self.frame.width - getTotalSpacingWidth()) / 2 - getFirstHalfItemWidth() - rightSpacing
                } else {
                    alignmentLeftSpacing = (self.frame.width - buttonItems[buttonItems.count/2].frame.width - getTotalSpacingWidth()) / 2 - getFirstHalfItemWidth() - rightSpacing
                }
            }
        } else if alignment == .fit {
            if buttonItems.count > 1 {
                alignmentLeftSpacing = 0
                self.interspacing = (self.frame.width - getTotalItemWidth() - leftSpacing - rightSpacing) / CGFloat(buttonItems.count - 1)
            } else {
                setAlignment(alignment: .centered)
            }
        } else {
            alignmentLeftSpacing = 0
        }
    }
    
    public func setInterspacing(interspacing: CGFloat) {
        self.interspacing = interspacing
        adjustAlignment()
    }
    
    public func setSpacing(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) {
        self.topSpacing = top
        self.leftSpacing = left
        self.bottomSpacing = bottom
        self.rightSpacing = right
        adjustAlignment()
    }
    
    // MARK: Helpers
    func adjustAlignment() {
        setAlignment(alignment: self.alignment)
    }
    
    func getTotalItemWidth() -> CGFloat {
        var totalWidth: CGFloat = 0
        for item in buttonItems {
            totalWidth += item.frame.width
        }
        return totalWidth
    }
    
    func getFirstHalfItemWidth() -> CGFloat {
        var halfWidth: CGFloat = 0
        for index in 0..<buttonItems.count/2 {
            halfWidth += buttonItems[index].frame.width
        }
        return halfWidth
    }
    
    func getTotalSpacingWidth() -> CGFloat {
        return interspacing * CGFloat(buttonItems.count - 1)
    }
    
    func scrollToPage(sender: UIButton) {
        let index = buttonItems.index(of: sender)
        let indexPath = IndexPath(item: 0, section: index!)
        controller?.scrollToPage(indexPath)
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
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PageMenuBar: UICollectionViewDelegateFlowLayout {
    
    // Cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemForIndexPath(indexPath as IndexPath).frame.width, height: itemForIndexPath(indexPath as IndexPath).frame.height)
    }
    
    // Interspacing
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interspacing
    }
    
    // Padding
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if !overflow {
            return UIEdgeInsetsMake(topSpacing, leftSpacing + alignmentLeftSpacing, bottomSpacing, rightSpacing)
        }
        else {
            return UIEdgeInsetsMake(topSpacing, overflowLeftSpacing, bottomSpacing, overflowRightSpacing)
        }
    }
    
    // Set initial scroll position on overflow
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !scrolledOnOverflow && overflow {
            var indexToScrollTo = IndexPath(item: 0, section: 0)
            // Middle and centered alignment are the same when there is overflow (i.e. centering on the middle element)
            if alignment == .middle || alignment == .centered {
                indexToScrollTo = IndexPath(item: buttonItems.count / 2, section: 0)
            }
            else if alignment == .right {
                indexToScrollTo = IndexPath(item: buttonItems.count - 1, section: 0)
            }
            collectionView.scrollToItem(at: indexToScrollTo, at: .centeredHorizontally, animated: false)
            scrolledOnOverflow = true
        }
    }
}
