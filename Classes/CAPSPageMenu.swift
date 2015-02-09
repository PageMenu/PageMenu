//  CAPSPageMenu.swift
//
//  Niklas Fahl
//
//  Copyright (c) 2014 The Board of Trustees of The University of Alabama All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  Neither the name of the University nor the names of the contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import UIKit

@objc public protocol CAPSPageMenuDelegate {
    // MARK: - Delegate functions
    
    optional func willMoveToPage(controller: UIViewController, index: Int)
    optional func didMoveToPage(controller: UIViewController, index: Int)
}

class MenuItemView: UIView {
    // MARK: - Menu item view
    
    var titleLabel : UILabel?
    var menuItemSeparator : UIView?
    
    func setUpMenuItemView(menuItemWidth: CGFloat, menuScrollViewHeight: CGFloat, indicatorHeight: CGFloat, separatorPercentageHeight: CGFloat, separatorWidth: CGFloat, separatorRoundEdges: Bool, menuItemSeparatorColor: UIColor) {
        titleLabel = UILabel(frame: CGRectMake(0.0, 0.0, menuItemWidth, menuScrollViewHeight - indicatorHeight))
        
        menuItemSeparator = UIView(frame: CGRectMake(menuItemWidth - (separatorWidth / 2), floor(menuScrollViewHeight * ((1.0 - separatorPercentageHeight) / 2.0)), separatorWidth, floor(menuScrollViewHeight * separatorPercentageHeight)))
        menuItemSeparator!.backgroundColor = menuItemSeparatorColor
        
        if separatorRoundEdges {
            menuItemSeparator!.layer.cornerRadius = menuItemSeparator!.frame.width / 2
        }
        
        menuItemSeparator!.hidden = true
        self.addSubview(menuItemSeparator!)
        
        self.addSubview(titleLabel!)
    }
    
    func setTitleText(text: NSString) {
        if titleLabel != nil {
            titleLabel!.text = text
            titleLabel!.numberOfLines = 0
            titleLabel!.sizeToFit()
        }
    }
}

public class CAPSPageMenu: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    let menuScrollView = UIScrollView()
    let controllerScrollView = UIScrollView()
    var controllerArray : [AnyObject] = []
    var menuItems : [MenuItemView] = []
    var menuItemWidths : [CGFloat] = []
    
    public var menuHeight : CGFloat = 34.0
    public var menuMargin : CGFloat = 15.0
    public var menuItemWidth : CGFloat = 111.0
    public var selectionIndicatorHeight : CGFloat = 3.0
    var totalMenuItemWidthIfDifferentWidths : CGFloat = 0.0
    public var scrollAnimationDurationOnMenuItemTap : Int = 500 // Millisecons
    var startingMenuMargin : CGFloat = 0.0
    
    var selectionIndicatorView : UIView = UIView()
    
    var currentPageIndex : Int = 0
    var lastPageIndex : Int = 0
    
    public var selectionIndicatorColor : UIColor = UIColor.whiteColor()
    public var selectedMenuItemLabelColor : UIColor = UIColor.whiteColor()
    public var unselectedMenuItemLabelColor : UIColor = UIColor.lightGrayColor()
    public var scrollMenuBackgroundColor : UIColor = UIColor.blackColor()
    public var viewBackgroundColor : UIColor = UIColor.whiteColor()
    public var bottomMenuHairlineColor : UIColor = UIColor.whiteColor()
    public var menuItemSeparatorColor : UIColor = UIColor.lightGrayColor()
    
    public var menuItemFont : UIFont = UIFont(name: "HelveticaNeue", size: 15.0)!
    public var menuItemSeparatorPercentageHeight : CGFloat = 0.2
    public var menuItemSeparatorWidth : CGFloat = 0.5
    public var menuItemSeparatorRoundEdges : Bool = false
    
    public var addBottomMenuHairline : Bool = true
    public var menuItemWidthBasedOnTitleTextWidth : Bool = false
    public var useMenuLikeSegmentedControl : Bool = false
    public var centerMenuItems : Bool = false
    public var enableHorizontalBounce : Bool = true
    public var hideTopMenuBar : Bool = false
    
    var currentOrientationIsPortrait : Bool = true
    var pageIndexForOrientationChange : Int = 0
    var didLayoutSubviewsAfterRotation : Bool = false
    var didScrollAlready : Bool = false
    
    var lastControllerScrollViewContentOffset : CGFloat = 0.0
    
    var lastScrollDirection : String = ""
    var startingPageForScroll : Int = 0
    var didTapMenuItemToScroll : Bool = false
    
    var pagesAddedDictionary : [Int : Int] = [:]
    
    public var delegate : CAPSPageMenuDelegate?
    
    var tapTimer : NSTimer?
    
    // MARK: - View life cycle
    
    /**
    Initialize PageMenu with view controllers
    
    :param: viewControllers List of view controllers that must be subclasses of UIViewController
    :param: frame Frame for page menu view
    :param: options Dictionary holding any customization options user might want to set
    */
    public init(viewControllers: [AnyObject], frame: CGRect, options: [String: AnyObject]?) {
        super.init(nibName: nil, bundle: nil)
        
        controllerArray = viewControllers
        
        self.view.frame = frame
        
        if options != nil {
            for key : String in options!.keys {
                if key == "selectionIndicatorHeight" {
                    selectionIndicatorHeight = options![key] as CGFloat
                } else if key == "menuItemSeparatorWidth" {
                    menuItemSeparatorWidth = options![key] as CGFloat
                } else if key == "scrollMenuBackgroundColor" {
                    scrollMenuBackgroundColor = options![key] as UIColor
                } else if key == "viewBackgroundColor" {
                    viewBackgroundColor = options![key] as UIColor
                } else if key == "bottomMenuHairlineColor" {
                    bottomMenuHairlineColor = options![key] as UIColor
                } else if key == "selectionIndicatorColor" {
                    selectionIndicatorColor = options![key] as UIColor
                } else if key == "menuItemSeparatorColor" {
                    menuItemSeparatorColor = options![key] as UIColor
                } else if key == "menuMargin" {
                    menuMargin = options![key] as CGFloat
                } else if key == "menuHeight" {
                    menuHeight = options![key] as CGFloat
                } else if key == "selectedMenuItemLabelColor" {
                    selectedMenuItemLabelColor = options![key] as UIColor
                } else if key == "unselectedMenuItemLabelColor" {
                    unselectedMenuItemLabelColor = options![key] as UIColor
                } else if key == "useMenuLikeSegmentedControl" {
                    useMenuLikeSegmentedControl = options![key] as Bool
                } else if key == "menuItemSeparatorRoundEdges" {
                    menuItemSeparatorRoundEdges = options![key] as Bool
                } else if key == "menuItemFont" {
                    menuItemFont = options![key] as UIFont
                } else if key == "menuItemSeparatorPercentageHeight" {
                    menuItemSeparatorPercentageHeight = options![key] as CGFloat
                } else if key == "menuItemWidth" {
                    menuItemWidth = options![key] as CGFloat
                } else if key == "enableHorizontalBounce" {
                    enableHorizontalBounce = options![key] as Bool
                } else if key == "addBottomMenuHairline" {
                    addBottomMenuHairline = options![key] as Bool
                } else if key == "menuItemWidthBasedOnTitleTextWidth" {
                    menuItemWidthBasedOnTitleTextWidth = options![key] as Bool
                } else if key == "scrollAnimationDurationOnMenuItemTap" {
                    scrollAnimationDurationOnMenuItemTap = options![key] as Int
                } else if key == "centerMenuItems" {
                    centerMenuItems = options![key] as Bool
                } else if key == "hideTopMenuBar" {
                    hideTopMenuBar = options![key] as Bool
                }
            }
            
            if hideTopMenuBar {
                addBottomMenuHairline = false
                menuHeight = 0.0
            }
        }
        
        setUpUserInterface()
        
        if menuScrollView.subviews.count == 0 {
            configureUserInterface()
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UI Setup
    
    func setUpUserInterface() {
        let viewsDictionary = ["menuScrollView":menuScrollView, "controllerScrollView":controllerScrollView]
        
        // Set up controller scroll view
        controllerScrollView.pagingEnabled = true
        controllerScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        controllerScrollView.alwaysBounceHorizontal = enableHorizontalBounce
        controllerScrollView.bounces = enableHorizontalBounce
        
        controllerScrollView.frame = CGRectMake(0.0, menuHeight, self.view.frame.width, self.view.frame.height - menuHeight)
        
        self.view.addSubview(controllerScrollView)
        
        let controllerScrollView_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[controllerScrollView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let controllerScrollView_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|[controllerScrollView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        
        self.view.addConstraints(controllerScrollView_constraint_H)
        self.view.addConstraints(controllerScrollView_constraint_V)
        
        // Set up menu scroll view
        menuScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        menuScrollView.frame = CGRectMake(0.0, 0.0, self.view.frame.width, menuHeight)
        
        self.view.addSubview(menuScrollView)
        
        let menuScrollView_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[menuScrollView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let menuScrollView_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:[menuScrollView(\(menuHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        
        self.view.addConstraints(menuScrollView_constraint_H)
        self.view.addConstraints(menuScrollView_constraint_V)
        
        // Add hairline to menu scroll view
        if addBottomMenuHairline {
            var menuBottomHairline : UIView = UIView()
            
            menuBottomHairline.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            self.view.addSubview(menuBottomHairline)
            
            let menuBottomHairline_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[menuBottomHairline]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
            let menuBottomHairline_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(menuHeight)-[menuBottomHairline(0.5)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
            
            self.view.addConstraints(menuBottomHairline_constraint_H)
            self.view.addConstraints(menuBottomHairline_constraint_V)
            
            menuBottomHairline.backgroundColor = bottomMenuHairlineColor
        }
        
        // Disable scroll bars
        menuScrollView.showsHorizontalScrollIndicator = false
        menuScrollView.showsVerticalScrollIndicator = false
        controllerScrollView.showsHorizontalScrollIndicator = false
        controllerScrollView.showsVerticalScrollIndicator = false
        
        // Set background color behind scroll views and for menu scroll view
        self.view.backgroundColor = viewBackgroundColor
        menuScrollView.backgroundColor = scrollMenuBackgroundColor
    }
    
    func configureUserInterface() {
        // Add tap gesture recognizer to controller scroll view to recognize menu item selection
        let menuItemTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleMenuItemTap:"))
        menuItemTapGestureRecognizer.numberOfTapsRequired = 1
        menuItemTapGestureRecognizer.numberOfTouchesRequired = 1
        menuItemTapGestureRecognizer.delegate = self
        menuScrollView.addGestureRecognizer(menuItemTapGestureRecognizer)
        
        // Set delegate for controller scroll view
        controllerScrollView.delegate = self
        
        // When the user taps the status bar, the scroll view beneath the touch which is closest to the status bar will be scrolled to top,
        // but only if its `scrollsToTop` property is YES, its delegate does not return NO from `shouldScrollViewScrollToTop`, and it is not already at the top.
        // If more than one scroll view is found, none will be scrolled.
        // Disable scrollsToTop for menu and controller scroll views so that iOS finds scroll views within our pages on status bar tap gesture.
        menuScrollView.scrollsToTop = false;
        controllerScrollView.scrollsToTop = false;
        
        // Configure menu scroll view
        if useMenuLikeSegmentedControl {
            menuScrollView.scrollEnabled = false
            menuScrollView.contentSize = CGSizeMake(self.view.frame.width, menuHeight)
            menuMargin = 0.0
        } else {
            menuScrollView.contentSize = CGSizeMake((menuItemWidth + menuMargin) * CGFloat(controllerArray.count) + menuMargin, menuHeight)
        }
        
        // Configure controller scroll view content size
        controllerScrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(controllerArray.count), 0.0)
        
        var index : CGFloat = 0.0
        
        for controller in controllerArray {
            if controller.isKindOfClass(UIViewController) {
                if index == 0.0 {
                    // Add first two controllers to scrollview and as child view controller
                    (controller as UIViewController).viewWillAppear(true)
                    addPageAtIndex(0)
                    (controller as UIViewController).viewDidAppear(true)
                }
                
                // Set up menu item for menu scroll view
                var menuItemFrame : CGRect = CGRect()
                
                if useMenuLikeSegmentedControl {
                    menuItemFrame = CGRectMake(self.view.frame.width / CGFloat(controllerArray.count) * CGFloat(index), 0.0, CGFloat(self.view.frame.width) / CGFloat(controllerArray.count), menuHeight)
                } else if menuItemWidthBasedOnTitleTextWidth {
                    var controllerTitle : String? = (controller as UIViewController).title
                    
                    var titleText : String = controllerTitle != nil ? controllerTitle! : "Menu \(Int(index) + 1)"
                    
                    var itemWidthRect : CGRect = (titleText as NSString).boundingRectWithSize(CGSizeMake(1000, 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:menuItemFont], context: nil)
                    
                    menuItemWidth = itemWidthRect.width
                    
                    menuItemFrame = CGRectMake(totalMenuItemWidthIfDifferentWidths + menuMargin + (menuMargin * index), 0.0, menuItemWidth, menuHeight)
                    
                    totalMenuItemWidthIfDifferentWidths += itemWidthRect.width
                    menuItemWidths.append(itemWidthRect.width)
                } else {
                    if centerMenuItems && index == 0.0  {
                        startingMenuMargin = ((self.view.frame.width - ((CGFloat(controllerArray.count) * menuItemWidth) + (CGFloat(controllerArray.count - 1) * menuMargin))) / 2.0) -  menuMargin
                        
                        if startingMenuMargin < 0.0 {
                            startingMenuMargin = 0.0
                        }
                        
                        menuItemFrame = CGRectMake(startingMenuMargin + menuMargin, 0.0, menuItemWidth, menuHeight)
                    } else {
                        menuItemFrame = CGRectMake(menuItemWidth * index + menuMargin * (index + 1) + startingMenuMargin, 0.0, menuItemWidth, menuHeight)
                    }
                }
                
                var menuItemView : MenuItemView = MenuItemView(frame: menuItemFrame)
                if useMenuLikeSegmentedControl {
                    menuItemView.setUpMenuItemView(CGFloat(self.view.frame.width) / CGFloat(controllerArray.count), menuScrollViewHeight: menuHeight, indicatorHeight: selectionIndicatorHeight, separatorPercentageHeight: menuItemSeparatorPercentageHeight, separatorWidth: menuItemSeparatorWidth, separatorRoundEdges: menuItemSeparatorRoundEdges, menuItemSeparatorColor: menuItemSeparatorColor)
                } else {
                    menuItemView.setUpMenuItemView(menuItemWidth, menuScrollViewHeight: menuHeight, indicatorHeight: selectionIndicatorHeight, separatorPercentageHeight: menuItemSeparatorPercentageHeight, separatorWidth: menuItemSeparatorWidth, separatorRoundEdges: menuItemSeparatorRoundEdges, menuItemSeparatorColor: menuItemSeparatorColor)
                }
                
                // Configure menu item label font if font is set by user
                menuItemView.titleLabel!.font = menuItemFont
                
                menuItemView.titleLabel!.textAlignment = NSTextAlignment.Center
                menuItemView.titleLabel!.textColor = unselectedMenuItemLabelColor
                
                // Set title depending on if controller has a title set
                if (controller as UIViewController).title != nil {
                    menuItemView.titleLabel!.text = controller.title!
                } else {
                    menuItemView.titleLabel!.text = "Menu \(Int(index) + 1)"
                }
                
                // Add separator between menu items when using as segmented control
                if useMenuLikeSegmentedControl {
                    if Int(index) < controllerArray.count - 1 {
                        menuItemView.menuItemSeparator!.hidden = false
                    }
                }
                
                // Add menu item view to menu scroll view
                menuScrollView.addSubview(menuItemView)
                menuItems.append(menuItemView)
                
                index++
            }
        }
        
        // Set new content size for menu scroll view if needed
        if menuItemWidthBasedOnTitleTextWidth {
            menuScrollView.contentSize = CGSizeMake((totalMenuItemWidthIfDifferentWidths + menuMargin) + CGFloat(controllerArray.count) * menuMargin, menuHeight)
        }
        
        // Set selected color for title label of selected menu item
        if menuItems.count > 0 {
            if menuItems[currentPageIndex].titleLabel != nil {
                menuItems[currentPageIndex].titleLabel!.textColor = selectedMenuItemLabelColor
            }
        }
        
        // Configure selection indicator view
        var selectionIndicatorFrame : CGRect = CGRect()
        
        if useMenuLikeSegmentedControl {
            selectionIndicatorFrame = CGRectMake(0.0, menuHeight - selectionIndicatorHeight, self.view.frame.width / CGFloat(controllerArray.count), selectionIndicatorHeight)
        } else if menuItemWidthBasedOnTitleTextWidth {
            selectionIndicatorFrame = CGRectMake(menuMargin, menuHeight - selectionIndicatorHeight, menuItemWidths[0], selectionIndicatorHeight)
        } else {
            if centerMenuItems  {
                selectionIndicatorFrame = CGRectMake(startingMenuMargin + menuMargin, menuHeight - selectionIndicatorHeight, menuItemWidth, selectionIndicatorHeight)
            } else {
                selectionIndicatorFrame = CGRectMake(menuMargin, menuHeight - selectionIndicatorHeight, menuItemWidth, selectionIndicatorHeight)
            }
        }
        
        selectionIndicatorView = UIView(frame: selectionIndicatorFrame)
        selectionIndicatorView.backgroundColor = selectionIndicatorColor
        menuScrollView.addSubview(selectionIndicatorView)
    }
    
    
    // MARK: - Scroll view delegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if !didLayoutSubviewsAfterRotation {
            if scrollView.isEqual(controllerScrollView) {
                if scrollView.contentOffset.x >= 0.0 && scrollView.contentOffset.x <= (CGFloat(controllerArray.count - 1) * self.view.frame.width) {
                    if (currentOrientationIsPortrait && self.interfaceOrientation.isPortrait) || (!currentOrientationIsPortrait && self.interfaceOrientation.isLandscape) {
                        // Check if scroll direction changed
                        if !didTapMenuItemToScroll {
                            if didScrollAlready {
                                var newScrollDirection : String  = ""
                                
                                if (CGFloat(startingPageForScroll) * scrollView.frame.width > scrollView.contentOffset.x) {
                                    newScrollDirection = "right"
                                } else if (CGFloat(startingPageForScroll) * scrollView.frame.width < scrollView.contentOffset.x) {
                                    newScrollDirection = "left"
                                }
                                
                                if newScrollDirection != "" {
                                    if !lastScrollDirection.isEqual(newScrollDirection) {
                                        var index : Int = newScrollDirection == "left" ? currentPageIndex + 1 : currentPageIndex - 1
                                        
                                        if index >= 0 && index < controllerArray.count {
                                            // Check dictionary if page was already added
                                            if pagesAddedDictionary[index] != index {
                                                addPageAtIndex(index)
                                                pagesAddedDictionary[index] = index
                                            }
                                        }
                                    }
                                }
                                
                                lastScrollDirection = newScrollDirection
                            }
                            
                            if !didScrollAlready {
                                if (lastControllerScrollViewContentOffset > scrollView.contentOffset.x) {
                                    if currentPageIndex != controllerArray.count - 1 {
                                        // Add page to the left of current page
                                        var index : Int = currentPageIndex - 1
                                        
                                        if pagesAddedDictionary[index] != index && index < controllerArray.count && index >= 0 {
                                            addPageAtIndex(index)
                                            pagesAddedDictionary[index] = index
                                        }
                                        
                                        lastScrollDirection = "right"
                                    }
                                } else if (lastControllerScrollViewContentOffset < scrollView.contentOffset.x) {
                                    if currentPageIndex != 0 {
                                        // Add page to the right of current page
                                        var index : Int = currentPageIndex + 1
                                        
                                        if pagesAddedDictionary[index] != index && index < controllerArray.count && index >= 0 {
                                            addPageAtIndex(index)
                                            pagesAddedDictionary[index] = index
                                        }
                                        
                                        lastScrollDirection = "left"
                                    }
                                }
                                
                                didScrollAlready = true
                            }
                            
                            lastControllerScrollViewContentOffset = scrollView.contentOffset.x
                        }
                        
                        var ratio : CGFloat = 1.0
                        
                        
                        // Calculate ratio between scroll views
                        ratio = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
                        
                        if menuScrollView.contentSize.width > self.view.frame.width {
                            var offset : CGPoint = menuScrollView.contentOffset
                            offset.x = controllerScrollView.contentOffset.x * ratio
                            menuScrollView.setContentOffset(offset, animated: false)
                        }
                        
                        // Calculate current page
                        var width : CGFloat = controllerScrollView.frame.size.width;
                        var page : Int = Int((controllerScrollView.contentOffset.x + (0.5 * width)) / width)
                        
                        // Update page if changed
                        if page != currentPageIndex {
                            lastPageIndex = currentPageIndex
                            currentPageIndex = page
                            
                            if pagesAddedDictionary[page] != page && page < controllerArray.count && page >= 0 {
                                addPageAtIndex(page)
                                pagesAddedDictionary[page] = page
                            }
                            
                            if !didTapMenuItemToScroll {
                                // Add last page to pages dictionary to make sure it gets removed after scrolling
                                if pagesAddedDictionary[lastPageIndex] != lastPageIndex {
                                    pagesAddedDictionary[lastPageIndex] = lastPageIndex
                                }
                                
                                // Make sure only up to 3 page views are in memory when fast scrolling, otherwise there should only be one in memory
                                var indexLeftTwo : Int = page - 2
                                if pagesAddedDictionary[indexLeftTwo] == indexLeftTwo {
                                    pagesAddedDictionary.removeValueForKey(indexLeftTwo)
                                    removePageAtIndex(indexLeftTwo)
                                }
                                var indexRightTwo : Int = page + 2
                                if pagesAddedDictionary[indexRightTwo] == indexRightTwo {
                                    pagesAddedDictionary.removeValueForKey(indexRightTwo)
                                    removePageAtIndex(indexRightTwo)
                                }
                            }
                        }
                        
                        // Move selection indicator view when swiping
                        moveSelectionIndicator(page)
                    }
                } else {
                    var ratio : CGFloat = 1.0
                    
                    ratio = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
                    
                    if menuScrollView.contentSize.width > self.view.frame.width {
                        var offset : CGPoint = menuScrollView.contentOffset
                        offset.x = controllerScrollView.contentOffset.x * ratio
                        menuScrollView.setContentOffset(offset, animated: false)
                    }
                }
            }
        } else {
            didLayoutSubviewsAfterRotation = false
            
            // Move selection indicator view when swiping
            moveSelectionIndicator(currentPageIndex)
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.isEqual(controllerScrollView) {
            // Call didMoveToPage delegate function
            var currentController : UIViewController = controllerArray[currentPageIndex] as UIViewController
            delegate?.didMoveToPage?(currentController, index: currentPageIndex)
            
            // Remove all but current page after decelerating
            for key in pagesAddedDictionary.keys {
                if key != currentPageIndex {
                    removePageAtIndex(key)
                }
            }
            
            didScrollAlready = false
            startingPageForScroll = currentPageIndex
            
            
            // Empty out pages in dictionary
            pagesAddedDictionary.removeAll(keepCapacity: false)
        }
    }
    
    func scrollViewDidEndTapScrollingAnimation() {
        // Call didMoveToPage delegate function
        var currentController : UIViewController = controllerArray[currentPageIndex] as UIViewController
        delegate?.didMoveToPage?(currentController, index: currentPageIndex)
        
        // Remove all but current page after decelerating
        for key in pagesAddedDictionary.keys {
            if key != currentPageIndex {
                removePageAtIndex(key)
            }
        }
        
        startingPageForScroll = currentPageIndex
        didTapMenuItemToScroll = false
        
        // Empty out pages in dictionary
        pagesAddedDictionary.removeAll(keepCapacity: false)
    }
    
    
    // MARK: - Handle Selection Indicator
    func moveSelectionIndicator(pageIndex: Int) {
        if pageIndex >= 0 && pageIndex < controllerArray.count {
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                var selectionIndicatorWidth : CGFloat = self.selectionIndicatorView.frame.width
                var selectionIndicatorX : CGFloat = 0.0
                
                if self.useMenuLikeSegmentedControl {
                    selectionIndicatorX = CGFloat(pageIndex) * (self.view.frame.width / CGFloat(self.controllerArray.count))
                    selectionIndicatorWidth = self.view.frame.width / CGFloat(self.controllerArray.count)
                } else if self.menuItemWidthBasedOnTitleTextWidth {
                    selectionIndicatorWidth = self.menuItemWidths[pageIndex]
                    selectionIndicatorX += self.menuMargin
                    
                    if pageIndex > 0 {
                        for i in 0...(pageIndex - 1) {
                            selectionIndicatorX += (self.menuMargin + self.menuItemWidths[i])
                        }
                    }
                } else {
                    if self.centerMenuItems && pageIndex == 0 {
                        selectionIndicatorX = self.startingMenuMargin + self.menuMargin
                    } else {
                        selectionIndicatorX = self.menuItemWidth * CGFloat(pageIndex) + self.menuMargin * CGFloat(pageIndex + 1) + self.startingMenuMargin
                    }
                }
                
                self.selectionIndicatorView.frame = CGRectMake(selectionIndicatorX, self.selectionIndicatorView.frame.origin.y, selectionIndicatorWidth, self.selectionIndicatorView.frame.height)
                
                // Switch newly selected menu item title label to selected color and old one to unselected color
                if self.menuItems.count > 0 {
                    if self.menuItems[self.lastPageIndex].titleLabel != nil && self.menuItems[self.currentPageIndex].titleLabel != nil {
                        self.menuItems[self.lastPageIndex].titleLabel!.textColor = self.unselectedMenuItemLabelColor
                        self.menuItems[self.currentPageIndex].titleLabel!.textColor = self.selectedMenuItemLabelColor
                    }
                }
            })
        }
    }
    
    
    // MARK: - Tap gesture recognizer selector
    
    func handleMenuItemTap(gestureRecognizer : UITapGestureRecognizer) {
        var tappedPoint : CGPoint = gestureRecognizer.locationInView(menuScrollView)
        
        if tappedPoint.y < menuScrollView.frame.height {
            
            // Calculate tapped page
            var itemIndex : Int = 0
            
            if useMenuLikeSegmentedControl {
                itemIndex = Int(tappedPoint.x / (self.view.frame.width / CGFloat(controllerArray.count)))
            } else if menuItemWidthBasedOnTitleTextWidth {
                // Base case being first item
                var menuItemLeftBound : CGFloat = 0.0
                var menuItemRightBound : CGFloat = menuItemWidths[0] + menuMargin + (menuMargin / 2)
                
                if !(tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound) {
                    for i in 1...controllerArray.count - 1 {
                        menuItemLeftBound = menuItemRightBound + 1.0
                        menuItemRightBound = menuItemLeftBound + menuItemWidths[i] + menuMargin
                        
                        if tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound {
                            itemIndex = i
                            break
                        }
                    }
                }
            } else {
                var rawItemIndex : CGFloat = ((tappedPoint.x - startingMenuMargin) - menuMargin / 2) / (menuMargin + menuItemWidth)
                
                // Prevent moving to first item when tapping left to first item
                if rawItemIndex < 0 {
                    itemIndex = -1
                } else {
                    itemIndex = Int(rawItemIndex)
                }
            }
            
            if itemIndex >= 0 && itemIndex < controllerArray.count {
                // Update page if changed
                if itemIndex != currentPageIndex {
                    startingPageForScroll = itemIndex
                    lastPageIndex = currentPageIndex
                    currentPageIndex = itemIndex
                    didTapMenuItemToScroll = true
                    
                    // Add pages in between current and tapped page if necessary
                    var smallerIndex : Int = lastPageIndex < currentPageIndex ? lastPageIndex : currentPageIndex
                    var largerIndex : Int = lastPageIndex > currentPageIndex ? lastPageIndex : currentPageIndex
                    
                    if smallerIndex + 1 != largerIndex {
                        for index in (smallerIndex + 1)...(largerIndex - 1) {
                            if pagesAddedDictionary[index] != index {
                                addPageAtIndex(index)
                                pagesAddedDictionary[index] = index
                            }
                        }
                    }
                    
                    addPageAtIndex(itemIndex)
                    
                    // Add page from which tap is initiated so it can be removed after tap is done
                    pagesAddedDictionary[lastPageIndex] = lastPageIndex
                }
                
                // Move controller scroll view when tapping menu item
                var duration : Double = Double(scrollAnimationDurationOnMenuItemTap) / Double(1000)
                
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    var xOffset : CGFloat = CGFloat(itemIndex) * self.controllerScrollView.frame.width
                    self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
                })
                
                if tapTimer != nil {
                    tapTimer!.invalidate()
                }
                
                var timerInterval : NSTimeInterval = Double(scrollAnimationDurationOnMenuItemTap) * 0.001
                tapTimer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "scrollViewDidEndTapScrollingAnimation", userInfo: nil, repeats: false)
            }
        }
    }
    
    
    // MARK: - Remove/Add Page
    func addPageAtIndex(index : Int) {
        // Call didMoveToPage delegate function
        var currentController : UIViewController = controllerArray[index] as UIViewController
        delegate?.willMoveToPage?(currentController, index: index)
        
        var newVC : UIViewController = controllerArray[index] as UIViewController
        
        newVC.willMoveToParentViewController(self)
        
        newVC.view.frame = CGRectMake(self.view.frame.width * CGFloat(index), menuHeight, self.view.frame.width, self.view.frame.height - menuHeight)
        
        self.addChildViewController(newVC)
        self.controllerScrollView.addSubview(newVC.view)
        newVC.didMoveToParentViewController(self)
    }
    
    func removePageAtIndex(index : Int) {
        var oldVC : UIViewController = controllerArray[index] as UIViewController
        
        oldVC.willMoveToParentViewController(nil)
        
        oldVC.view.removeFromSuperview()
        oldVC.removeFromParentViewController()
        
        oldVC.didMoveToParentViewController(nil)
    }
    
    
    // MARK: - Orientation Change
    
    override public func viewDidLayoutSubviews() {
        // Configure controller scroll view content size
        controllerScrollView.contentSize = CGSizeMake(self.view.frame.width * CGFloat(controllerArray.count), self.view.frame.height - menuHeight)

        var oldCurrentOrientationIsPortrait : Bool = currentOrientationIsPortrait
        currentOrientationIsPortrait = self.interfaceOrientation.isPortrait
        
        if (oldCurrentOrientationIsPortrait && UIDevice.currentDevice().orientation.isLandscape) || (!oldCurrentOrientationIsPortrait && UIDevice.currentDevice().orientation.isPortrait) {
            didLayoutSubviewsAfterRotation = true
            
            //Resize menu items if using as segmented control
            if useMenuLikeSegmentedControl {
                menuScrollView.contentSize = CGSizeMake(self.view.frame.width, menuHeight)
                
                // Resize selectionIndicator bar
                var selectionIndicatorX : CGFloat = CGFloat(currentPageIndex) * (self.view.frame.width / CGFloat(self.controllerArray.count))
                var selectionIndicatorWidth : CGFloat = self.view.frame.width / CGFloat(self.controllerArray.count)
                selectionIndicatorView.frame =  CGRectMake(selectionIndicatorX, self.selectionIndicatorView.frame.origin.y, selectionIndicatorWidth, self.selectionIndicatorView.frame.height)
                
                // Resize menu items
                var index : Int = 0
                
                for item : MenuItemView in menuItems as [MenuItemView] {
                    item.frame = CGRectMake(self.view.frame.width / CGFloat(controllerArray.count) * CGFloat(index), 0.0, self.view.frame.width / CGFloat(controllerArray.count), menuHeight)
                    item.titleLabel!.frame = CGRectMake(0.0, 0.0, self.view.frame.width / CGFloat(controllerArray.count), menuHeight)
                    item.menuItemSeparator!.frame = CGRectMake(item.frame.width - (menuItemSeparatorWidth / 2), item.menuItemSeparator!.frame.origin.y, item.menuItemSeparator!.frame.width, item.menuItemSeparator!.frame.height)
                    
                    index++
                }
            } else if centerMenuItems {
                startingMenuMargin = ((self.view.frame.width - ((CGFloat(controllerArray.count) * menuItemWidth) + (CGFloat(controllerArray.count - 1) * menuMargin))) / 2.0) -  menuMargin
                
                if startingMenuMargin < 0.0 {
                    startingMenuMargin = 0.0
                }
                
                var selectionIndicatorX : CGFloat = self.menuItemWidth * CGFloat(currentPageIndex) + self.menuMargin * CGFloat(currentPageIndex + 1) + self.startingMenuMargin
                selectionIndicatorView.frame =  CGRectMake(selectionIndicatorX, self.selectionIndicatorView.frame.origin.y, self.selectionIndicatorView.frame.width, self.selectionIndicatorView.frame.height)
                
                // Recalculate frame for menu items if centered
                var index : Int = 0
                
                for item : MenuItemView in menuItems as [MenuItemView] {
                    if index == 0 {
                        item.frame = CGRectMake(startingMenuMargin + menuMargin, 0.0, menuItemWidth, menuHeight)
                    } else {
                        item.frame = CGRectMake(menuItemWidth * CGFloat(index) + menuMargin * CGFloat(index + 1) + startingMenuMargin, 0.0, menuItemWidth, menuHeight)
                    }
                    
                    index++
                }
            }
            
            for view : UIView in controllerScrollView.subviews as [UIView] {
                view.frame = CGRectMake(self.view.frame.width * CGFloat(currentPageIndex), menuHeight, controllerScrollView.frame.width, self.view.frame.height - menuHeight)
            }
            
            var xOffset : CGFloat = CGFloat(self.currentPageIndex) * controllerScrollView.frame.width
            controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: controllerScrollView.contentOffset.y), animated: false)
            
            var ratio : CGFloat = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
            
            if menuScrollView.contentSize.width > self.view.frame.width {
                var offset : CGPoint = menuScrollView.contentOffset
                offset.x = controllerScrollView.contentOffset.x * ratio
                menuScrollView.setContentOffset(offset, animated: false)
            }
        }
        
        // Hsoi 2015-02-05 - Running on iOS 7.1 complained: "'NSInternalInconsistencyException', reason: 'Auto Layout 
        // still required after sending -viewDidLayoutSubviews to the view controller. ViewController's implementation 
        // needs to send -layoutSubviews to the view to invoke auto layout.'"
        //
        // http://stackoverflow.com/questions/15490140/auto-layout-error
        //
        // Given the SO answer and caveats presented there, we'll call layoutIfNeeded() instead.
        self.view.layoutIfNeeded()
    }
    
    
    // MARK: - Move to page index
    
    /**
    Move to page at index
    
    :param: index Index of the page to move to
    */
    public func moveToPage(index: Int) {
        if index >= 0 && index < controllerArray.count {
            // Update page if changed
            if index != currentPageIndex {
                startingPageForScroll = index
                lastPageIndex = currentPageIndex
                currentPageIndex = index
                didTapMenuItemToScroll = true
                
                // Add pages in between current and tapped page if necessary
                var smallerIndex : Int = lastPageIndex < currentPageIndex ? lastPageIndex : currentPageIndex
                var largerIndex : Int = lastPageIndex > currentPageIndex ? lastPageIndex : currentPageIndex
                
                if smallerIndex + 1 != largerIndex {
                    for i in (smallerIndex + 1)...(largerIndex - 1) {
                        if pagesAddedDictionary[i] != i {
                            addPageAtIndex(i)
                            pagesAddedDictionary[i] = i
                        }
                    }
                }
                
                addPageAtIndex(index)
                
                // Add page from which tap is initiated so it can be removed after tap is done
                pagesAddedDictionary[lastPageIndex] = lastPageIndex
            }
            
            // Move controller scroll view when tapping menu item
            var duration : Double = Double(scrollAnimationDurationOnMenuItemTap) / Double(1000)
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                var xOffset : CGFloat = CGFloat(index) * self.controllerScrollView.frame.width
                self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
            })
        }
    }
}
