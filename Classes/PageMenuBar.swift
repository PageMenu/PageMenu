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

// Change the size of the bar items to be variable or uniform
public enum Sizing {
    case uniform
    case variable
}
open class PageMenuBar: UIToolbar {
    //internal var itemContainer: UICollectionView?
    
    // MARK: - Properties
    var reuseIdentifier = "MenuCell"
    
    // Main properties
    open var controller: PageMenuController?
    open var collectionView: UICollectionView?
    open var barItems: [UIButton] = []
    open var indicator: UIView = UIView(frame: CGRect(x: 30, y: 20, width: 5, height: 2))
    fileprivate var selectedItem: UIButton?
    
    // Customization properties
    public fileprivate(set) var alignment: Alignment = .left
    public fileprivate(set) var sizing: Sizing = .variable
    public fileprivate(set) var uniformItemWidth: CGFloat? = nil
    public fileprivate(set) var interspacing: CGFloat = 0
    public fileprivate(set) var topSpacing: CGFloat = 0
    public fileprivate(set) var leftSpacing: CGFloat = 0
    public fileprivate(set) var bottomSpacing: CGFloat = 0
    public fileprivate(set) var rightSpacing: CGFloat = 0
    public fileprivate(set) var defaultIndicatorColor: UIColor = UIColor.blue
    
    // Alignment calculated properties
    fileprivate var alignmentLeftSpacing: CGFloat = 0
    fileprivate var fitInterspacing: CGFloat = 0
    
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
        addSubview(indicator)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 200.0
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
                if barItems.count % 2 == 0 {
                    alignmentLeftSpacing = (self.frame.width - getTotalSpacingWidth()) / 2 - getFirstHalfItemWidth() - rightSpacing
                } else {
                    alignmentLeftSpacing = (self.frame.width - barItems[barItems.count/2].frame.width - getTotalSpacingWidth()) / 2 - getFirstHalfItemWidth() - rightSpacing
                }
            }
        } else if alignment == .fit {
            if barItems.count > 1 {
                alignmentLeftSpacing = 0
                self.fitInterspacing = (self.frame.width - getTotalItemWidth() - leftSpacing - rightSpacing) / CGFloat(barItems.count - 1)
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
    
    public func setSizing(sizing: Sizing) {
        if sizing == .uniform {
            self.sizing = .uniform
            adjustUniformItemWidth()
            adjustAlignment()
        } else {
            self.sizing = .variable
            sizeToFitItems()
        }
    }
    
    public func setUniformItemWidth(width: CGFloat) {
        self.uniformItemWidth = width
        if sizing == .uniform {
            adjustAlignment()
        }
    }
    
    public func sizeToFitItems() {
        if sizing == .uniform {
            adjustUniformItemWidth()
        } else {
            for item in barItems {
                sizeItemToFit(item)
            }
        }
    }
    
    public func setBarHeight(height: CGFloat) {
        self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: height)
        collectionView!.frame = CGRect(x: 0, y: 0, width: collectionView!.frame.width, height: height)
        sizeToFitItems()
    }
    
    public func setDefaultIndicatorColor(color: UIColor) {
        self.defaultIndicatorColor = color
        adjustIndicator()
    }
    
    // MARK: Add/Remove Items
    internal func addItem(title: String, at: Int) {
        let item = UIButton()
        item.setTitle(title, for: .normal)
        if sizing == .variable {
            sizeItemToFit(item)
        } else {
            sizeItemToFit(item)
            item.frame.size = CGSize(width: getUniformItemWidth(), height: item.frame.height)
        }
        item.addTarget(self, action: #selector(scrollToPage), for: .touchUpInside)
        barItems.insert(item, at: at)
        adjustAlignment()
    }
    
    internal func addItem(image: UIImage, at: Int) {
        let item = UIButton()
        item.setImage(image, for: .normal)
        if sizing == .variable {
            sizeItemToFit(item)
        } else {
            sizeItemToFit(item)
            item.frame.size = CGSize(width: getUniformItemWidth(), height: item.frame.height)
        }
        sizeItemToFit(item)
        item.addTarget(self, action: #selector(scrollToPage), for: .touchUpInside)
        barItems.insert(item, at: at)
        adjustAlignment()
    }
    
    internal func removeItem(at: Int) {
        barItems.remove(at: at)
        adjustAlignment()
    }
    
    // MARK: Helpers
    fileprivate func adjustAlignment() {
        if sizing == .uniform {
            adjustUniformItemWidth()
        }
        sizeToFitItems()
        setAlignment(alignment: self.alignment)
        adjustIndicator()
    }
    
    fileprivate func adjustIndicator() {
        if barItems.count == 0 {
            indicator.backgroundColor = UIColor.clear
        } else {
            guard let selectedItem = selectedItem else {
                self.selectedItem = barItems[0]
                return
            }
            indicator.backgroundColor = defaultIndicatorColor
            indicator.frame.origin.y = collectionView!.frame.height - indicator.frame.height
            indicator.frame.origin.x = selectedItem.bounds.origin.x + leftSpacing
            indicator.frame.size = CGSize(width: selectedItem.frame.width, height: indicator.frame.height)
        }
    }
    
    fileprivate func adjustUniformItemWidth() {
        for item in barItems {
            item.frame.size = CGSize(width: getUniformItemWidth(), height: item.frame.height)
        }
    }
    
    fileprivate func getUniformItemWidth() -> CGFloat {
        guard let uniformItemWidth = uniformItemWidth else {
            return ((collectionView!.frame.width - leftSpacing - rightSpacing) / CGFloat(barItems.count)) - (interspacing / 2)
        }
        return uniformItemWidth
    }
    
    fileprivate func getTotalItemWidth() -> CGFloat {
        var totalWidth: CGFloat = 0
        for item in barItems {
            totalWidth += item.frame.width
        }
        return totalWidth
    }
    
    fileprivate func getFirstHalfItemWidth() -> CGFloat {
        var halfWidth: CGFloat = 0
        for index in 0..<barItems.count/2 {
            halfWidth += barItems[index].frame.width
        }
        return halfWidth
    }
    
    fileprivate func getTotalSpacingWidth() -> CGFloat {
        return interspacing * CGFloat(barItems.count - 1)
    }
    
    fileprivate func sizeItemToFit(_ item: UIButton) {
        item.sizeToFit()
        item.frame.size = CGSize(width: item.frame.width, height: collectionView!.frame.height)
    }
    
    // MARK: Item Pressed
    func scrollToPage(sender: UIButton) {
        let index = barItems.index(of: sender)
        let indexPath = IndexPath(item: 0, section: index!)
        selectedItem = sender
        adjustIndicator()
        controller!.scrollToPage(indexPath)
    }
}

// MARK: - ItemForIndexPath
extension PageMenuBar {
    func itemForIndexPath(_ indexPath: IndexPath) -> UIButton {
        return barItems[(indexPath as NSIndexPath).item]
    }
}


// MARK: - UICollectionViewDataSource
extension PageMenuBar: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return barItems.count
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
    
    // Interpacing
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if alignment == .fit {
            return fitInterspacing
        } else {
            return interspacing
        }
    }
    
    // Interspacing for uniform sizing with fit alignment
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if alignment == .fit && sizing == .uniform {
            return fitInterspacing
        } else {
            return 0
        }
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
                indexToScrollTo = IndexPath(item: barItems.count / 2, section: 0)
            }
            else if alignment == .right {
                indexToScrollTo = IndexPath(item: barItems.count - 1, section: 0)
            }
            collectionView.scrollToItem(at: indexToScrollTo, at: .centeredHorizontally, animated: false)
            scrolledOnOverflow = true
        }
    }
}
