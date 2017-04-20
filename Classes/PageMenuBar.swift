//
//  PageMenuBar.swift
//  PageMenu
//
//  Created by Grayson Webster on 3/31/17.
//  Copyright © 2017 Center for Advanced Public Safety. All rights reserved.
//

import Foundation

// How the bar items are aligned
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

//
public enum IndicatorMovement {
    case synced
    case halfDelayed
    case delayed
}
public enum OverflowScrollMovement {
    case smooth
    case centering
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
    fileprivate var lastSelectedItem: UIButton?
    
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
    public fileprivate(set) var indicatorMovement: IndicatorMovement = .halfDelayed
    public fileprivate(set) var selectionColor: UIColor = UIColor.blue
    public fileprivate(set) var defaultColor: UIColor = UIColor.darkGray
    public fileprivate(set) var useDefaultColors: Bool = true
    public fileprivate(set) var defaultSelectedPageIndex: Int = 0
    public fileprivate(set) var isInNavigationBar: Bool = false
    public fileprivate(set) var navBarMargin: CGFloat = 0.0
    public fileprivate(set) var overflowScrollMovement: OverflowScrollMovement = .centering
    
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
        collectionView!.addSubview(indicator)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
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
            if getTotalSpacingWidth() + getTotalItemWidth() > self.collectionView!.frame.width {
                self.overflow = true
            } else {
                alignmentLeftSpacing = 0
            }
        } else if alignment == .centered {
            if getTotalSpacingWidth() + getTotalItemWidth() > self.collectionView!.frame.width {
                self.overflow = true
            } else {
                alignmentLeftSpacing = (self.collectionView!.frame.width - getTotalItemWidth() - getTotalSpacingWidth()) / 2 - rightSpacing
            }
        } else if alignment == .right {
            if getTotalSpacingWidth() + getTotalItemWidth() > self.collectionView!.frame.width {
                self.overflow = true
            } else {
                alignmentLeftSpacing = self.collectionView!.frame.width - getTotalItemWidth() - getTotalSpacingWidth() - leftSpacing - rightSpacing
            }
        } else if alignment == .middle {
            if getTotalSpacingWidth() + getTotalItemWidth() > self.collectionView!.frame.width {
                self.overflow = true
            } else {
                if barItems.count % 2 == 0 {
                    alignmentLeftSpacing = (self.collectionView!.frame.width - getTotalSpacingWidth()) / 2 - getFirstHalfItemWidth() - rightSpacing
                } else {
                    alignmentLeftSpacing = (self.collectionView!.frame.width - barItems[barItems.count/2].frame.width - getTotalSpacingWidth()) / 2 - getFirstHalfItemWidth() - rightSpacing
                }
            }
        } else if alignment == .fit {
            if barItems.count > 1 {
                alignmentLeftSpacing = 0
                self.fitInterspacing = (self.collectionView!.frame.width - getTotalItemWidth() - leftSpacing - rightSpacing) / CGFloat(barItems.count - 1)
            } else {
                setAlignment(alignment: .centered)
            }
        } else {
            alignmentLeftSpacing = 0
        }
        adjustIndicator()
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
        adjustIndicator()
    }
    
    public func setDefaultIndicatorColor(color: UIColor) {
        self.defaultIndicatorColor = color
        adjustIndicator()
    }
    
    public func setIndicatorMovement(movement: IndicatorMovement) {
        self.indicatorMovement = movement
        adjustAlignment()
    }
    
    public func setSelectionColor(color: UIColor) {
        self.selectionColor = color
    }
    
    public func setDefaultColor(color: UIColor) {
        self.defaultColor = color
    }
    
    public func setUseDefaultColors(selection: Bool) {
        self.useDefaultColors = selection
    }
    
    public func setDefaultSelectedPageIndex(index: Int) {
        self.defaultSelectedPageIndex = index
        adjustIndicator()
    }
    
    public func setIsInNavigationBar(margin: CGFloat) {
        isInNavigationBar = true
        navBarMargin = margin
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
        if useDefaultColors {
            item.setTitleColor(self.defaultColor, for: .normal)
        }
        if barItems.count == 0 {
            selectedItem = item
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
    
    // MARK: Animate Indicator
    
    open func moveIndicator(_ offset: CGFloat, _ stoppedScrolling: Bool) {
        let pageIndex = Int(round(offset / self.frame.width))
        if pageIndex >= 0 && pageIndex < barItems.count && ((stoppedScrolling && self.indicatorMovement == .delayed) || self.indicatorMovement != .delayed) {
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                var indicatorWidth : CGFloat = self.indicator.frame.width
                var indicatorX : CGFloat = 0.0
                indicatorWidth = self.barItems[pageIndex].frame.width
                if self.overflow {
                    indicatorX += self.leftSpacing + self.alignmentLeftSpacing + self.overflowLeftSpacing
                    if self.overflowScrollMovement == .smooth {
                        let ratio =  (self.getContentWidth() - self.frame.width) / (UIScreen.main.bounds.width * CGFloat(self.barItems.count) - self.frame.width)
                        self.collectionView!.setContentOffset(CGPoint(x: ratio * offset, y: 0), animated: true)
                    } else {
                        
                    }
                } else {
                    indicatorX += self.leftSpacing + self.alignmentLeftSpacing
                }
                if self.indicatorMovement == .synced {
                    let thing = (self.collectionView!.frame.width - self.leftSpacing - self.rightSpacing) / CGFloat(self.barItems.count) - ((self.interspacing) / 2)
                    let thing2 = thing - (self.getTotalItemWidth() / CGFloat(self.barItems.count))
                    indicatorX += offset / CGFloat(self.barItems.count) - ((thing2 - ((self.interspacing - self.navBarMargin) / 2)) * (offset / self.frame.width))
                } else {
                    indicatorX += self.getSpacingWidthUntil(index: pageIndex) + self.getItemWidthUntil(index: pageIndex)
                }
                
                self.indicator.frame = CGRect(x: indicatorX, y: self.indicator.frame.origin.y, width: indicatorWidth, height: self.indicator.frame.height)
                self.lastSelectedItem = self.selectedItem
                self.selectedItem = self.barItems[pageIndex]
                self.switchColors()
            })
        }
    }
    
    open func moveIndicator(index: Int, _ stoppedScrolling: Bool) {
        let pageIndex = index
        if pageIndex >= 0 && pageIndex < barItems.count && ((stoppedScrolling && self.indicatorMovement == .delayed) || self.indicatorMovement != .delayed) {
            UIView.animate(withDuration: 0, animations: { () -> Void in
                var indicatorWidth : CGFloat = self.indicator.frame.width
                var indicatorX : CGFloat = 0.0
                indicatorWidth = self.barItems[pageIndex].frame.width
                if self.overflow {
                    indicatorX += self.leftSpacing + self.alignmentLeftSpacing + self.overflowLeftSpacing
                } else {
                    indicatorX += self.leftSpacing + self.alignmentLeftSpacing
                }
                indicatorX += self.getSpacingWidthUntil(index: pageIndex) + self.getItemWidthUntil(index: pageIndex)
                self.indicator.frame = CGRect(x: indicatorX, y: self.indicator.frame.origin.y, width: indicatorWidth, height: self.indicator.frame.height)
                self.lastSelectedItem = self.selectedItem
                self.selectedItem = self.barItems[self.defaultSelectedPageIndex]
                self.switchColors()
                
            })
        }
    }
    
    // MARK: Helpers
    
    open func adjustAlignment() {
        sizeToFitItems()
        setAlignment(alignment: self.alignment)
    }
    
    fileprivate func adjustIndicator() {
        if barItems.count == 0 {
            indicator.backgroundColor = UIColor.clear
        } else {
            indicator.backgroundColor = defaultIndicatorColor
            indicator.frame.size = CGSize(width: self.selectedItem!.frame.width, height: indicator.frame.height)
            indicator.frame.origin.y = collectionView!.frame.height - indicator.frame.height
            indicator.frame.origin.x = leftSpacing
            if defaultSelectedPageIndex > 0 {
                controller!.scrollToPage(IndexPath(item: 0, section: 0)) // To allow scroll calculations to reset
                let indexPath = IndexPath(item: 0, section: defaultSelectedPageIndex)
                controller!.scrollToPage(indexPath)
            }
            moveIndicator(index: defaultSelectedPageIndex, true)
        }
    }
    
    fileprivate func switchColors() {
        if useDefaultColors {
            self.lastSelectedItem?.setTitleColor(self.defaultColor, for: .normal)
            self.selectedItem?.setTitleColor(self.selectionColor, for: .normal)
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
    
    public func getContentWidth() -> CGFloat {
        if overflow {
            return getTotalSpacingWidth() + getTotalItemWidth() + leftSpacing + rightSpacing + overflowRightSpacing + overflowRightSpacing
        }
        return getTotalSpacingWidth() + getTotalItemWidth() + leftSpacing + rightSpacing
    }
    
    public func getTotalItemWidth() -> CGFloat {
        var totalWidth: CGFloat = 0
        for item in barItems {
            totalWidth += item.frame.width
        }
        return totalWidth
    }
    
    public func getItemWidthUntil(index: Int) -> CGFloat {
        var totalWidth: CGFloat = 0
        for item in 0..<index {
            totalWidth += barItems[item].frame.width
        }
        return totalWidth
    }
    
    public func getFirstHalfItemWidth() -> CGFloat {
        var halfWidth: CGFloat = 0
        for index in 0..<barItems.count/2 {
            halfWidth += barItems[index].frame.width
        }
        return halfWidth
    }
    
    public func getTotalSpacingWidth() -> CGFloat {
        return interspacing * CGFloat(barItems.count - 1)
    }
    
    public func getSpacingWidthUntil(index: Int) -> CGFloat {
        return interspacing * CGFloat(index)
    }
    
    fileprivate func sizeItemToFit(_ item: UIButton) {
        item.sizeToFit()
        item.frame.size = CGSize(width: item.frame.width, height: collectionView!.frame.height)
    }
    
    // MARK: Item Pressed
    func scrollToPage(sender: UIButton) {
        let index = barItems.index(of: sender)
        let indexPath = IndexPath(item: 0, section: index!)
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
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
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
            return interspacing
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
}
