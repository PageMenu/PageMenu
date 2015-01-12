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

class MenuItemView: UIView {
    
    var titleLabel : UILabel?
    
    func setUpMenuItemView(menuItemWidth: CGFloat, menuScrollViewHeight: CGFloat, indicatorHeight: CGFloat) {
        titleLabel = UILabel(frame: CGRectMake(0.0, 0.0, menuItemWidth, menuScrollViewHeight - indicatorHeight))
        
        self.addSubview(titleLabel!)
    }
    
    func setTitleText(text: NSString) {
        if titleLabel != nil {
            titleLabel!.text = text
        }
    }
}

class CAPSPageMenu: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    let menuScrollView = UIScrollView()
    let controllerScrollView = UIScrollView()
    var controllerArray : [AnyObject] = []
    var menuItems : [MenuItemView] = []
    var menuItemWidths : [CGFloat] = []
    
    var menuHeight : CGFloat = 34.0
    var menuMargin : CGFloat = 15.0
    var menuItemWidth : CGFloat = 111.0
    var selectionIndicatorHeight : CGFloat = 3.0
    var totalMenuItemWidthIfDifferentWidths : CGFloat = 0.0
    
    var selectionIndicatorView : UIView = UIView()
    
    var currentPageIndex : Int = 0
    var lastPageIndex : Int = 0
    
    var selectionIndicatorColor : UIColor = UIColor.whiteColor()
    var selectedMenuItemLabelColor : UIColor = UIColor.whiteColor()
    var unselectedMenuItemLabelColor : UIColor = UIColor.lightGrayColor()
    var scrollMenuBackgroundColor : UIColor = UIColor.blackColor()
    var viewBackgroundColor : UIColor = UIColor.whiteColor()
    var bottomMenuHairlineColor : UIColor = UIColor.whiteColor()
    
    var menuItemFont : UIFont = UIFont(name: "HelveticaNeue", size: 15.0)!
    
    var addBottomMenuHairline : Bool = true
    var menuItemWidthBasedOnTitleTextWidth : Bool = false
    
    var currentOrientationIsPortrait : Bool = true
    var pageIndexForOrientationChange : Int = 0
    var didLayoutSubviewsAfterRotation : Bool = false
    
    
    // MARK: - View life cycle
    
    init(viewControllers: [AnyObject]) {
        super.init(nibName: nil, bundle: nil)
        
        controllerArray = viewControllers
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpUserInterface()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        configureUserInterface()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - UI Setup
    
    func setUpUserInterface() {
        // Set up menu scroll view
        menuScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.view.addSubview(menuScrollView)
        
        let viewsDictionary = ["menuScrollView":menuScrollView, "controllerScrollView":controllerScrollView]
        
        let menuScrollView_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[menuScrollView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let menuScrollView_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:[menuScrollView(\(menuHeight))]", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        
        self.view.addConstraints(menuScrollView_constraint_H)
        self.view.addConstraints(menuScrollView_constraint_V)
        
        // Set up controller scroll view
        controllerScrollView.pagingEnabled = true
        controllerScrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.view.addSubview(controllerScrollView)
        
        let controllerScrollView_constraint_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[controllerScrollView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let controllerScrollView_constraint_V:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|[controllerScrollView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        
        self.view.addConstraints(controllerScrollView_constraint_H)
        self.view.addConstraints(controllerScrollView_constraint_V)
        
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
        controllerScrollView.addGestureRecognizer(menuItemTapGestureRecognizer)
        
        // Set delegate for controller scroll view
        controllerScrollView.delegate = self
        
        // Configure menu scroll view content size
        menuScrollView.contentSize = CGSizeMake((menuItemWidth + menuMargin) * CGFloat(controllerArray.count) + menuMargin, menuScrollView.frame.height)
        
        // Configure controller scroll view content size
        controllerScrollView.contentSize = CGSizeMake(controllerScrollView.frame.width * CGFloat(controllerArray.count), controllerScrollView.frame.height)
        
        var index : CGFloat = 0.0
        
        for controller in controllerArray {
            if controller.isKindOfClass(UIViewController) {
                // Add controller to scrollview and as child view controller
                self.addChildViewController(controller as UIViewController)
                (controller as UIViewController).view.frame = CGRectMake(controllerScrollView.frame.width * index, menuScrollView.frame.height, controllerScrollView.frame.width, controllerScrollView.frame.height - menuScrollView.frame.height)
                controllerScrollView.addSubview((controller as UIViewController).view)
                self.didMoveToParentViewController(self)
                
                // Set up menu item for menu scroll view
                var menuItemFrame : CGRect = CGRect()
                
                if menuItemWidthBasedOnTitleTextWidth {
                    var controllerTitle : String? = (controller as UIViewController).title
                    
                    var titleText : String = controllerTitle != nil ? controllerTitle! : "Menu \(Int(index) + 1)"
                    
                    var itemWidthRect : CGRect = (titleText as NSString).boundingRectWithSize(CGSizeMake(1000, 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:menuItemFont], context: nil)
                    
                    menuItemWidth = itemWidthRect.width
                    
                    menuItemFrame = CGRectMake(totalMenuItemWidthIfDifferentWidths + menuMargin + (menuMargin * index), 0.0, menuItemWidth, menuScrollView.frame.height)
                    
                    totalMenuItemWidthIfDifferentWidths += itemWidthRect.width
                    menuItemWidths.append(itemWidthRect.width)
                } else {
                    menuItemFrame = CGRectMake(menuItemWidth * index + menuMargin * (index + 1), 0.0, menuItemWidth, menuScrollView.frame.height)
                }
                
                var menuItemView : MenuItemView = MenuItemView(frame: menuItemFrame)
                menuItemView.setUpMenuItemView(menuItemWidth, menuScrollViewHeight: menuScrollView.frame.height, indicatorHeight: selectionIndicatorHeight)
                
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
                
                // Add menu item view to menu scroll view
                menuScrollView.addSubview(menuItemView)
                menuItems.append(menuItemView)
                
                index++
            }
        }
        
        // Set new content size for menu scroll view if needed
        if menuItemWidthBasedOnTitleTextWidth {
            menuScrollView.contentSize = CGSizeMake((totalMenuItemWidthIfDifferentWidths + menuMargin) + CGFloat(controllerArray.count) * menuMargin, menuScrollView.frame.height)
        }
        
        // Set selected color for title label of selected menu item
        if menuItems.count > 0 {
            if menuItems[currentPageIndex].titleLabel != nil {
                menuItems[currentPageIndex].titleLabel!.textColor = selectedMenuItemLabelColor
            }
        }
        
        // Configure selection indicator view
        var selectionIndicatorFrame : CGRect = CGRect()
        
        if menuItemWidthBasedOnTitleTextWidth {
            selectionIndicatorFrame = CGRectMake(menuMargin, menuScrollView.frame.height - selectionIndicatorHeight, menuItemWidths[0], selectionIndicatorHeight)
        } else {
            selectionIndicatorFrame = CGRectMake(menuMargin, menuScrollView.frame.height - selectionIndicatorHeight, menuItemWidth, selectionIndicatorHeight)
        }
        
        selectionIndicatorView = UIView(frame: selectionIndicatorFrame)
        selectionIndicatorView.backgroundColor = selectionIndicatorColor
        menuScrollView.addSubview(selectionIndicatorView)
    }
    
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (currentOrientationIsPortrait && self.interfaceOrientation.isPortrait) || (!currentOrientationIsPortrait && self.interfaceOrientation.isLandscape) {
            var ratio : CGFloat = 1.0
            
            if scrollView.isEqual(controllerScrollView) {
                // Calculate ratio between scroll views
                ratio = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
                
                if menuScrollView.contentSize.width > self.view.frame.width {
                    var offset : CGPoint = menuScrollView.contentOffset
                    offset.x = controllerScrollView.contentOffset.x * ratio
                    menuScrollView.setContentOffset(offset, animated: false)
                }
                
                if didLayoutSubviewsAfterRotation {
                    didLayoutSubviewsAfterRotation = false
                } else {
                    // Calculate current page
                    var width : CGFloat = controllerScrollView.frame.size.width;
                    var page : Int = Int((controllerScrollView.contentOffset.x + (0.5 * width)) / width)
                    
                    // Update page if changed
                    if page != currentPageIndex {
                        lastPageIndex = currentPageIndex
                        currentPageIndex = page
                    }
                    
                    // Move selection indicator view when swiping
                    UIView.animateWithDuration(0.15, animations: { () -> Void in
                        var selectionIndicatorWidth : CGFloat = self.selectionIndicatorView.frame.width
                        var selectionIndicatorX : CGFloat = 0.0
                        
                        if self.menuItemWidthBasedOnTitleTextWidth {
                            selectionIndicatorWidth = self.menuItemWidths[page]
                            selectionIndicatorX += self.menuMargin
                            
                            if page > 0 {
                                for i in 0...(page - 1) {
                                    selectionIndicatorX += (self.menuMargin + self.menuItemWidths[i])
                                }
                            }
                        } else {
                            selectionIndicatorX = (self.menuMargin + self.menuItemWidth) * CGFloat(page) + self.menuMargin
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
        }
    }
    
    
    // MARK: - Tap gesture recognizer selector
    
    func handleMenuItemTap(gestureRecognizer : UITapGestureRecognizer) {
        var tappedPoint : CGPoint = gestureRecognizer.locationInView(menuScrollView)
        
        if tappedPoint.y < menuScrollView.frame.height {
            
            // Calculate tapped page
            var itemIndex : Int = 0
            
            if menuItemWidthBasedOnTitleTextWidth {
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
                itemIndex = Int((tappedPoint.x - menuMargin / 2) / (menuMargin + menuItemWidth))
            }
            
            // Update page if changed
            if itemIndex != currentPageIndex {
                lastPageIndex = currentPageIndex
                currentPageIndex = itemIndex
            }
            
            // Move controller scroll view when tapping menu item
            UIView.animateWithDuration(0.7, animations: { () -> Void in
                var xOffset : CGFloat = CGFloat(itemIndex) * self.controllerScrollView.frame.width
                self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: true)
            })
        }
    }
    
    
    // MARK: - Orientation Change
    
    override func viewDidLayoutSubviews() {
        var oldCurrentOrientationIsPortrait : Bool = currentOrientationIsPortrait
        currentOrientationIsPortrait = self.interfaceOrientation.isPortrait
        
        if (oldCurrentOrientationIsPortrait && UIDevice.currentDevice().orientation.isLandscape) || (!oldCurrentOrientationIsPortrait && UIDevice.currentDevice().orientation.isPortrait) {
            didLayoutSubviewsAfterRotation = true
            
            // Configure controller scroll view content size
            controllerScrollView.contentSize = CGSizeMake(controllerScrollView.frame.width * CGFloat(controllerArray.count), controllerScrollView.frame.height)
            
            var subviewIndex : CGFloat = 0.0
            
            for view : UIView in controllerScrollView.subviews as [UIView] {
                view.frame = CGRectMake(controllerScrollView.frame.width * subviewIndex, menuScrollView.frame.height, controllerScrollView.frame.width, controllerScrollView.frame.height - menuScrollView.frame.height)
                
                subviewIndex++
            }
            
            var xOffset : CGFloat = CGFloat(self.currentPageIndex) * controllerScrollView.frame.width
            controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: controllerScrollView.contentOffset.y), animated: true)
            
            var ratio : CGFloat = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
            
            if menuScrollView.contentSize.width > self.view.frame.width {
                var offset : CGPoint = menuScrollView.contentOffset
                offset.x = controllerScrollView.contentOffset.x * ratio
                menuScrollView.setContentOffset(offset, animated: false)
            }
        }
    }
}