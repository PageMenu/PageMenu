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

    @objc optional func willMoveToPage(_ controller: UIViewController, index: Int)
    @objc optional func didMoveToPage(_ controller: UIViewController, index: Int)
}

open class CAPSPageMenu: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    //MARK: - Configuration
    var configuration = CAPSPageMenuConfiguration()
    
    // MARK: - Properties

    let menuScrollView = UIScrollView()
    let controllerScrollView = UIScrollView()
    var controllerArray : [UIViewController] = []
    var menuItems : [MenuItemView] = []
    var menuItemWidths : [CGFloat] = []
    
    var totalMenuItemWidthIfDifferentWidths : CGFloat = 0.0
    
    var startingMenuMargin : CGFloat = 0.0
    var menuItemMargin : CGFloat = 0.0

    var selectionIndicatorView : UIView = UIView()

    var currentPageIndex : Int = 0
    var lastPageIndex : Int = 0

    var currentOrientationIsPortrait : Bool = true
    var pageIndexForOrientationChange : Int = 0
    var didLayoutSubviewsAfterRotation : Bool = false
    var didScrollAlready : Bool = false

    var lastControllerScrollViewContentOffset : CGFloat = 0.0

    var lastScrollDirection : CAPSPageMenuScrollDirection = .other
    var startingPageForScroll : Int = 0
    var didTapMenuItemToScroll : Bool = false

    var pagesAddedDictionary : [Int : Int] = [:]

    open weak var delegate : CAPSPageMenuDelegate?

    var tapTimer : Timer?

    enum CAPSPageMenuScrollDirection : Int {
        case left
        case right
        case other
    }

    // MARK: - View life cycle

    /**
     Initialize PageMenu with view controllers
     
     - parameter viewControllers: List of view controllers that must be subclasses of UIViewController
     - parameter frame: Frame for page menu view
     - parameter options: Dictionary holding any customization options user might want to set
     */
    public init(viewControllers: [UIViewController], frame: CGRect, options: [String: AnyObject]?) {
        super.init(nibName: nil, bundle: nil)
        
        controllerArray = viewControllers
        
        self.view.frame = frame
    }
    
    public convenience init(viewControllers: [UIViewController], frame: CGRect, pageMenuOptions: [CAPSPageMenuOption]?) {
        self.init(viewControllers:viewControllers, frame:frame, options:nil)
        
        if let options = pageMenuOptions {
            configurePageMenu(options: options)
        }
        
        setUpUserInterface()
        
        if menuScrollView.subviews.count == 0 {
            configureUserInterface()
        }
    }
    
    /**
    Initialize PageMenu with view controllers

    - parameter viewControllers: List of view controllers that must be subclasses of UIViewController
    - parameter frame: Frame for page menu view
    - parameter configuration: A configuration instance for page menu
    */
    public init(viewControllers: [UIViewController], frame: CGRect, configuration: CAPSPageMenuConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.configuration = configuration
        controllerArray = viewControllers

        self.view.frame = frame
        
        //Build UI
        setUpUserInterface()
        if menuScrollView.subviews.count == 0 {
            configureUserInterface()
        }
    }
    
    /**
     Initialize PageMenu with view controllers
     
     - parameter viewControllers: List of view controllers that must be subclasses of UIViewController
     - parameter storyBoard: Parent storyboard for rendering a page menu
     - parameter configuration: A configuration instance for page menu
     */
    public init(viewControllers: [UIViewController], inStoryBoard: UIViewController, with configuration: CAPSPageMenuConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.configuration = configuration
        controllerArray = viewControllers
        
        //Setup storyboard
        self.view.frame = CGRect(x: 0, y: 0, width: inStoryBoard.view.frame.size.width, height: inStoryBoard.view.frame.size.height)
        inStoryBoard.addChildViewController(self)
        inStoryBoard.view.addSubview(self.view)
        didMove(toParentViewController: inStoryBoard)
        
        //Build UI
        setUpUserInterface()
        if menuScrollView.subviews.count == 0 {
            configureUserInterface()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    // MARK: - UI Setup
    
    func configurePageMenu(options: [CAPSPageMenuOption]) {
        for option in options {
            switch (option) {
            case let .selectionIndicatorHeight(value):
                configuration.selectionIndicatorHeight = value
            case let .menuItemSeparatorWidth(value):
                configuration.menuItemSeparatorWidth = value
            case let .scrollMenuBackgroundColor(value):
                configuration.scrollMenuBackgroundColor = value
            case let .viewBackgroundColor(value):
                configuration.viewBackgroundColor = value
            case let .bottomMenuHairlineColor(value):
                configuration.bottomMenuHairlineColor = value
            case let .selectionIndicatorColor(value):
                configuration.selectionIndicatorColor = value
            case let .menuItemSeparatorColor(value):
                configuration.menuItemSeparatorColor = value
            case let .menuMargin(value):
                configuration.menuMargin = value
            case let .menuItemMargin(value):
                menuItemMargin = value
            case let .menuHeight(value):
                configuration.menuHeight = value
            case let .selectedMenuItemLabelColor(value):
                configuration.selectedMenuItemLabelColor = value
            case let .unselectedMenuItemLabelColor(value):
                configuration.unselectedMenuItemLabelColor = value
            case let .useMenuLikeSegmentedControl(value):
                configuration.useMenuLikeSegmentedControl = value
            case let .menuItemSeparatorRoundEdges(value):
                configuration.menuItemSeparatorRoundEdges = value
            case let .menuItemFont(value):
                configuration.menuItemFont = value
            case let .menuItemSeparatorPercentageHeight(value):
                configuration.menuItemSeparatorPercentageHeight = value
            case let .menuItemWidth(value):
                configuration.menuItemWidth = value
            case let .enableHorizontalBounce(value):
                configuration.enableHorizontalBounce = value
            case let .addBottomMenuHairline(value):
                configuration.addBottomMenuHairline = value
            case let .menuItemWidthBasedOnTitleTextWidth(value):
                configuration.menuItemWidthBasedOnTitleTextWidth = value
            case let .titleTextSizeBasedOnMenuItemWidth(value):
                configuration.titleTextSizeBasedOnMenuItemWidth = value
            case let .scrollAnimationDurationOnMenuItemTap(value):
                configuration.scrollAnimationDurationOnMenuItemTap = value
            case let .centerMenuItems(value):
                configuration.centerMenuItems = value
            case let .hideTopMenuBar(value):
                configuration.hideTopMenuBar = value
            }
        }
        
        if configuration.hideTopMenuBar {
            configuration.addBottomMenuHairline = false
            configuration.menuHeight = 0.0
        }
    }

    func setUpUserInterface() {
        let viewsDictionary = ["menuScrollView":menuScrollView, "controllerScrollView":controllerScrollView]

        // Set up controller scroll view
        controllerScrollView.isPagingEnabled = true
        controllerScrollView.translatesAutoresizingMaskIntoConstraints = false
        controllerScrollView.alwaysBounceHorizontal = configuration.enableHorizontalBounce
        controllerScrollView.bounces = configuration.enableHorizontalBounce

        controllerScrollView.frame = CGRect(x: 0.0, y: configuration.menuHeight, width: self.view.frame.width, height: self.view.frame.height - configuration.menuHeight)

        self.view.addSubview(controllerScrollView)

        let controllerScrollView_constraint_H:Array = NSLayoutConstraint.constraints(withVisualFormat: "H:|[controllerScrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let controllerScrollView_constraint_V:Array = NSLayoutConstraint.constraints(withVisualFormat: "V:|[controllerScrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)

        self.view.addConstraints(controllerScrollView_constraint_H)
        self.view.addConstraints(controllerScrollView_constraint_V)

        // Set up menu scroll view
        menuScrollView.translatesAutoresizingMaskIntoConstraints = false

        menuScrollView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: configuration.menuHeight)

        self.view.addSubview(menuScrollView)

        let menuScrollView_constraint_H:Array = NSLayoutConstraint.constraints(withVisualFormat: "H:|[menuScrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let menuScrollView_constraint_V:Array = NSLayoutConstraint.constraints(withVisualFormat: "V:[menuScrollView(\(configuration.menuHeight))]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)

        self.view.addConstraints(menuScrollView_constraint_H)
        self.view.addConstraints(menuScrollView_constraint_V)

        // Add hairline to menu scroll view
        if configuration.addBottomMenuHairline {
            let menuBottomHairline : UIView = UIView()

            menuBottomHairline.translatesAutoresizingMaskIntoConstraints = false

            self.view.addSubview(menuBottomHairline)

            let menuBottomHairline_constraint_H:Array = NSLayoutConstraint.constraints(withVisualFormat: "H:|[menuBottomHairline]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
            let menuBottomHairline_constraint_V:Array = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(configuration.menuHeight)-[menuBottomHairline(0.5)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])

            self.view.addConstraints(menuBottomHairline_constraint_H)
            self.view.addConstraints(menuBottomHairline_constraint_V)

            menuBottomHairline.backgroundColor = configuration.bottomMenuHairlineColor
        }

        // Disable scroll bars
        menuScrollView.showsHorizontalScrollIndicator = false
        menuScrollView.showsVerticalScrollIndicator = false
        controllerScrollView.showsHorizontalScrollIndicator = false
        controllerScrollView.showsVerticalScrollIndicator = false

        // Set background color behind scroll views and for menu scroll view
        self.view.backgroundColor = configuration.viewBackgroundColor
        menuScrollView.backgroundColor = configuration.scrollMenuBackgroundColor
    }

    func configureUserInterface() {
        // Add tap gesture recognizer to controller scroll view to recognize menu item selection
        let menuItemTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CAPSPageMenu.handleMenuItemTap(_:)))
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
        if configuration.useMenuLikeSegmentedControl {
            menuScrollView.isScrollEnabled = false
            menuScrollView.contentSize = CGSize(width: self.view.frame.width, height: configuration.menuHeight)
            configuration.menuMargin = 0.0
        } else {
            menuScrollView.contentSize = CGSize(width: (configuration.menuItemWidth + configuration.menuMargin) * CGFloat(controllerArray.count) + configuration.menuMargin, height: configuration.menuHeight)
        }

        // Configure controller scroll view content size
        controllerScrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(controllerArray.count), height: 0.0)

        var index : CGFloat = 0.0

        for controller in controllerArray {
            if index == 0.0 {
                // Add first two controllers to scrollview and as child view controller
                controller.viewWillAppear(true)
                addPageAtIndex(0)
                controller.viewDidAppear(true)
            }

            // Set up menu item for menu scroll view
            var menuItemFrame : CGRect = CGRect()

            if configuration.useMenuLikeSegmentedControl {
                //**************************拡張*************************************
                if menuItemMargin > 0 {
                    let marginSum = menuItemMargin * CGFloat(controllerArray.count + 1)
                    let menuItemWidth = (self.view.frame.width - marginSum) / CGFloat(controllerArray.count)
                    menuItemFrame = CGRect(x: CGFloat(menuItemMargin * (index + 1)) + menuItemWidth * CGFloat(index), y: 0.0, width: CGFloat(self.view.frame.width) / CGFloat(controllerArray.count), height: configuration.menuHeight)
                } else {
                    menuItemFrame = CGRect(x: self.view.frame.width / CGFloat(controllerArray.count) * CGFloat(index), y: 0.0, width: CGFloat(self.view.frame.width) / CGFloat(controllerArray.count), height: configuration.menuHeight)
                }
                //**************************拡張ここまで*************************************
            } else if configuration.menuItemWidthBasedOnTitleTextWidth {
                let controllerTitle : String? = controller.title

                let titleText : String = controllerTitle != nil ? controllerTitle! : "Menu \(Int(index) + 1)"
                let itemWidthRect : CGRect = (titleText as NSString).boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:configuration.menuItemFont], context: nil)
                configuration.menuItemWidth = itemWidthRect.width

                menuItemFrame = CGRect(x: totalMenuItemWidthIfDifferentWidths + configuration.menuMargin + (configuration.menuMargin * index), y: 0.0, width: configuration.menuItemWidth, height: configuration.menuHeight)

                totalMenuItemWidthIfDifferentWidths += itemWidthRect.width
                menuItemWidths.append(itemWidthRect.width)
            } else {
                if configuration.centerMenuItems && index == 0.0  {
                    startingMenuMargin = ((self.view.frame.width - ((CGFloat(controllerArray.count) * configuration.menuItemWidth) + (CGFloat(controllerArray.count - 1) * configuration.menuMargin))) / 2.0) -  configuration.menuMargin

                    if startingMenuMargin < 0.0 {
                        startingMenuMargin = 0.0
                    }

                    menuItemFrame = CGRect(x: startingMenuMargin + configuration.menuMargin, y: 0.0, width: configuration.menuItemWidth, height: configuration.menuHeight)
                } else {
                    menuItemFrame = CGRect(x: configuration.menuItemWidth * index + configuration.menuMargin * (index + 1) + startingMenuMargin, y: 0.0, width: configuration.menuItemWidth, height: configuration.menuHeight)
                }
            }

            let menuItemView : MenuItemView = MenuItemView(frame: menuItemFrame)
            menuItemView.configure(for: self, controller: controller, index: index)

            // Add menu item view to menu scroll view
            menuScrollView.addSubview(menuItemView)
            menuItems.append(menuItemView)

            index += 1
        }

        // Set new content size for menu scroll view if needed
        if configuration.menuItemWidthBasedOnTitleTextWidth {
            menuScrollView.contentSize = CGSize(width: (totalMenuItemWidthIfDifferentWidths + configuration.menuMargin) + CGFloat(controllerArray.count) * configuration.menuMargin, height: configuration.menuHeight)
        }

        // Set selected color for title label of selected menu item
        if menuItems.count > 0 {
            if menuItems[currentPageIndex].titleLabel != nil {
                menuItems[currentPageIndex].titleLabel!.textColor = configuration.selectedMenuItemLabelColor
            }
        }

        // Configure selection indicator view
        var selectionIndicatorFrame : CGRect = CGRect()

        if configuration.useMenuLikeSegmentedControl {
            selectionIndicatorFrame = CGRect(x: 0.0, y: configuration.menuHeight - configuration.selectionIndicatorHeight, width: self.view.frame.width / CGFloat(controllerArray.count), height: configuration.selectionIndicatorHeight)
        } else if configuration.menuItemWidthBasedOnTitleTextWidth {
            selectionIndicatorFrame = CGRect(x: configuration.menuMargin, y: configuration.menuHeight - configuration.selectionIndicatorHeight, width: menuItemWidths[0], height: configuration.selectionIndicatorHeight)
        } else {
            if configuration.centerMenuItems  {
                selectionIndicatorFrame = CGRect(x: startingMenuMargin + configuration.menuMargin, y: configuration.menuHeight - configuration.selectionIndicatorHeight, width: configuration.menuItemWidth, height: configuration.selectionIndicatorHeight)
            } else {
                selectionIndicatorFrame = CGRect(x: configuration.menuMargin, y: configuration.menuHeight - configuration.selectionIndicatorHeight, width: configuration.menuItemWidth, height: configuration.selectionIndicatorHeight)
            }
        }

        selectionIndicatorView = UIView(frame: selectionIndicatorFrame)
        selectionIndicatorView.backgroundColor = configuration.selectionIndicatorColor
        menuScrollView.addSubview(selectionIndicatorView)
    }


    // MARK: - Scroll view delegate

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !didLayoutSubviewsAfterRotation {
            if scrollView.isEqual(controllerScrollView) {
                if scrollView.contentOffset.x >= 0.0 && scrollView.contentOffset.x <= (CGFloat(controllerArray.count - 1) * self.view.frame.width) {
                    if (currentOrientationIsPortrait && UIApplication.shared.statusBarOrientation.isPortrait) || (!currentOrientationIsPortrait && UIApplication.shared.statusBarOrientation.isLandscape) {
                        // Check if scroll direction changed
                        if !didTapMenuItemToScroll {
                            if didScrollAlready {
                                var newScrollDirection : CAPSPageMenuScrollDirection = .other

                                if (CGFloat(startingPageForScroll) * scrollView.frame.width > scrollView.contentOffset.x) {
                                    newScrollDirection = .right
                                } else if (CGFloat(startingPageForScroll) * scrollView.frame.width < scrollView.contentOffset.x) {
                                    newScrollDirection = .left
                                }

                                if newScrollDirection != .other {
                                    if lastScrollDirection != newScrollDirection {
                                        let index : Int = newScrollDirection == .left ? currentPageIndex + 1 : currentPageIndex - 1

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
                                        let index : Int = currentPageIndex - 1

                                        if pagesAddedDictionary[index] != index && index < controllerArray.count && index >= 0 {
                                            addPageAtIndex(index)
                                            pagesAddedDictionary[index] = index
                                        }

                                        lastScrollDirection = .right
                                    }
                                } else if (lastControllerScrollViewContentOffset < scrollView.contentOffset.x) {
                                    if currentPageIndex != 0 {
                                        // Add page to the right of current page
                                        let index : Int = currentPageIndex + 1

                                        if pagesAddedDictionary[index] != index && index < controllerArray.count && index >= 0 {
                                            addPageAtIndex(index)
                                            pagesAddedDictionary[index] = index
                                        }

                                        lastScrollDirection = .left
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
                        let width : CGFloat = controllerScrollView.frame.size.width;
                        let page : Int = Int((controllerScrollView.contentOffset.x + (0.5 * width)) / width)

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
                                let indexLeftTwo : Int = page - 2
                                if pagesAddedDictionary[indexLeftTwo] == indexLeftTwo {
                                    pagesAddedDictionary.removeValue(forKey: indexLeftTwo)
                                    removePageAtIndex(indexLeftTwo)
                                }
                                let indexRightTwo : Int = page + 2
                                if pagesAddedDictionary[indexRightTwo] == indexRightTwo {
                                    pagesAddedDictionary.removeValue(forKey: indexRightTwo)
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

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isEqual(controllerScrollView) {
            // Call didMoveToPage delegate function
            let currentController = controllerArray[currentPageIndex]
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
            pagesAddedDictionary.removeAll(keepingCapacity: false)
        }
    }

    func scrollViewDidEndTapScrollingAnimation() {
        // Call didMoveToPage delegate function
        let currentController = controllerArray[currentPageIndex]
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
        pagesAddedDictionary.removeAll(keepingCapacity: false)
    }


    // MARK: - Handle Selection Indicator
    func moveSelectionIndicator(_ pageIndex: Int) {
        if pageIndex >= 0 && pageIndex < controllerArray.count {
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                var selectionIndicatorWidth : CGFloat = self.selectionIndicatorView.frame.width
                var selectionIndicatorX : CGFloat = 0.0

                if self.configuration.useMenuLikeSegmentedControl {
                    selectionIndicatorX = CGFloat(pageIndex) * (self.view.frame.width / CGFloat(self.controllerArray.count))
                    selectionIndicatorWidth = self.view.frame.width / CGFloat(self.controllerArray.count)
                } else if self.configuration.menuItemWidthBasedOnTitleTextWidth {
                    selectionIndicatorWidth = self.menuItemWidths[pageIndex]
                    selectionIndicatorX += self.configuration.menuMargin

                    if pageIndex > 0 {
                        for i in 0...(pageIndex - 1) {
                            selectionIndicatorX += (self.configuration.menuMargin + self.menuItemWidths[i])
                        }
                    }
                } else {
                    if self.configuration.centerMenuItems && pageIndex == 0 {
                        selectionIndicatorX = self.startingMenuMargin + self.configuration.menuMargin
                    } else {
                        selectionIndicatorX = self.configuration.menuItemWidth * CGFloat(pageIndex) + self.configuration.menuMargin * CGFloat(pageIndex + 1) + self.startingMenuMargin
                    }
                }

                self.selectionIndicatorView.frame = CGRect(x: selectionIndicatorX, y: self.selectionIndicatorView.frame.origin.y, width: selectionIndicatorWidth, height: self.selectionIndicatorView.frame.height)

                // Switch newly selected menu item title label to selected color and old one to unselected color
                if self.menuItems.count > 0 {
                    if self.menuItems[self.lastPageIndex].titleLabel != nil && self.menuItems[self.currentPageIndex].titleLabel != nil {
                        self.menuItems[self.lastPageIndex].titleLabel!.textColor = self.configuration.unselectedMenuItemLabelColor
                        self.menuItems[self.currentPageIndex].titleLabel!.textColor = self.configuration.selectedMenuItemLabelColor
                    }
                }
            })
        }
    }


    // MARK: - Tap gesture recognizer selector

    func handleMenuItemTap(_ gestureRecognizer : UITapGestureRecognizer) {
        let tappedPoint : CGPoint = gestureRecognizer.location(in: menuScrollView)

        if tappedPoint.y < menuScrollView.frame.height {

            // Calculate tapped page
            var itemIndex : Int = 0

            if configuration.useMenuLikeSegmentedControl {
                itemIndex = Int(tappedPoint.x / (self.view.frame.width / CGFloat(controllerArray.count)))
            } else if configuration.menuItemWidthBasedOnTitleTextWidth {
                // Base case being first item
                var menuItemLeftBound : CGFloat = 0.0
                var menuItemRightBound : CGFloat = menuItemWidths[0] + configuration.menuMargin + (configuration.menuMargin / 2)

                if !(tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound) {
                    for i in 1...controllerArray.count - 1 {
                        menuItemLeftBound = menuItemRightBound + 1.0
                        menuItemRightBound = menuItemLeftBound + menuItemWidths[i] + configuration.menuMargin

                        if tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound {
                            itemIndex = i
                            break
                        }
                    }
                }
            } else {
                let rawItemIndex : CGFloat = ((tappedPoint.x - startingMenuMargin) - configuration.menuMargin / 2) / (configuration.menuMargin + configuration.menuItemWidth)

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
                    let smallerIndex : Int = lastPageIndex < currentPageIndex ? lastPageIndex : currentPageIndex
                    let largerIndex : Int = lastPageIndex > currentPageIndex ? lastPageIndex : currentPageIndex

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
                let duration : Double = Double(configuration.scrollAnimationDurationOnMenuItemTap) / Double(1000)

                UIView.animate(withDuration: duration, animations: { () -> Void in
                    let xOffset : CGFloat = CGFloat(itemIndex) * self.controllerScrollView.frame.width
                    self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
                })

                if tapTimer != nil {
                    tapTimer!.invalidate()
                }

                let timerInterval : TimeInterval = Double(configuration.scrollAnimationDurationOnMenuItemTap) * 0.001
                tapTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(CAPSPageMenu.scrollViewDidEndTapScrollingAnimation), userInfo: nil, repeats: false)
            }
        }
    }


    // MARK: - Remove/Add Page
    func addPageAtIndex(_ index : Int) {
        // Call didMoveToPage delegate function
        let currentController = controllerArray[index]
        delegate?.willMoveToPage?(currentController, index: index)

        let newVC = controllerArray[index]

        newVC.willMove(toParentViewController: self)

        newVC.view.frame = CGRect(x: self.view.frame.width * CGFloat(index), y: configuration.menuHeight, width: self.view.frame.width, height: self.view.frame.height - configuration.menuHeight)

        self.addChildViewController(newVC)
        self.controllerScrollView.addSubview(newVC.view)
        newVC.didMove(toParentViewController: self)
    }

    func removePageAtIndex(_ index : Int) {
        let oldVC = controllerArray[index]

        oldVC.willMove(toParentViewController: nil)

        oldVC.view.removeFromSuperview()
        oldVC.removeFromParentViewController()

        oldVC.didMove(toParentViewController: nil)
    }


    // MARK: - Orientation Change

    override open func viewDidLayoutSubviews() {
        // Configure controller scroll view content size
        controllerScrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(controllerArray.count), height: self.view.frame.height - configuration.menuHeight)

        let oldCurrentOrientationIsPortrait : Bool = currentOrientationIsPortrait
        currentOrientationIsPortrait = UIDevice.current.orientation.isPortrait

        if (oldCurrentOrientationIsPortrait && UIDevice.current.orientation.isLandscape) || (!oldCurrentOrientationIsPortrait && UIDevice.current.orientation.isPortrait) {
            didLayoutSubviewsAfterRotation = true

            //Resize menu items if using as segmented control
            if configuration.useMenuLikeSegmentedControl {
                menuScrollView.contentSize = CGSize(width: self.view.frame.width, height: configuration.menuHeight)

                // Resize selectionIndicator bar
                let selectionIndicatorX : CGFloat = CGFloat(currentPageIndex) * (self.view.frame.width / CGFloat(self.controllerArray.count))
                let selectionIndicatorWidth : CGFloat = self.view.frame.width / CGFloat(self.controllerArray.count)
                selectionIndicatorView.frame =  CGRect(x: selectionIndicatorX, y: self.selectionIndicatorView.frame.origin.y, width: selectionIndicatorWidth, height: self.selectionIndicatorView.frame.height)

                // Resize menu items
                var index : Int = 0

                for item : MenuItemView in menuItems as [MenuItemView] {
                    item.frame = CGRect(x: self.view.frame.width / CGFloat(controllerArray.count) * CGFloat(index), y: 0.0, width: self.view.frame.width / CGFloat(controllerArray.count), height: configuration.menuHeight)
                    item.titleLabel!.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width / CGFloat(controllerArray.count), height: configuration.menuHeight)
                    item.menuItemSeparator!.frame = CGRect(x: item.frame.width - (configuration.menuItemSeparatorWidth / 2), y: item.menuItemSeparator!.frame.origin.y, width: item.menuItemSeparator!.frame.width, height: item.menuItemSeparator!.frame.height)

                    index += 1
                }
            } else if configuration.centerMenuItems {
                startingMenuMargin = ((self.view.frame.width - ((CGFloat(controllerArray.count) * configuration.menuItemWidth) + (CGFloat(controllerArray.count - 1) * configuration.menuMargin))) / 2.0) -  configuration.menuMargin

                if startingMenuMargin < 0.0 {
                    startingMenuMargin = 0.0
                }

                let selectionIndicatorX : CGFloat = self.configuration.menuItemWidth * CGFloat(currentPageIndex) + self.configuration.menuMargin * CGFloat(currentPageIndex + 1) + self.startingMenuMargin
                selectionIndicatorView.frame =  CGRect(x: selectionIndicatorX, y: self.selectionIndicatorView.frame.origin.y, width: self.selectionIndicatorView.frame.width, height: self.selectionIndicatorView.frame.height)

                // Recalculate frame for menu items if centered
                var index : Int = 0

                for item : MenuItemView in menuItems as [MenuItemView] {
                    if index == 0 {
                        item.frame = CGRect(x: startingMenuMargin + configuration.menuMargin, y: 0.0, width: configuration.menuItemWidth, height: configuration.menuHeight)
                    } else {
                        item.frame = CGRect(x: configuration.menuItemWidth * CGFloat(index) + configuration.menuMargin * CGFloat(index + 1) + startingMenuMargin, y: 0.0, width: configuration.menuItemWidth, height: configuration.menuHeight)
                    }

                    index += 1
                }
            }

            for view in controllerScrollView.subviews {
                view.frame = CGRect(x: self.view.frame.width * CGFloat(self.currentPageIndex), y: configuration.menuHeight, width: controllerScrollView.frame.width, height: self.view.frame.height - configuration.menuHeight)
            }

            let xOffset : CGFloat = CGFloat(self.currentPageIndex) * controllerScrollView.frame.width
            controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: controllerScrollView.contentOffset.y), animated: false)

            let ratio : CGFloat = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)

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

    - parameter index: Index of the page to move to
    */
    open func moveToPage(_ index: Int) {
        if index >= 0 && index < controllerArray.count {
            // Update page if changed
            if index != currentPageIndex {
                startingPageForScroll = index
                lastPageIndex = currentPageIndex
                currentPageIndex = index
                didTapMenuItemToScroll = true

                // Add pages in between current and tapped page if necessary
                let smallerIndex : Int = lastPageIndex < currentPageIndex ? lastPageIndex : currentPageIndex
                let largerIndex : Int = lastPageIndex > currentPageIndex ? lastPageIndex : currentPageIndex

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
            let duration : Double = Double(configuration.scrollAnimationDurationOnMenuItemTap) / Double(1000)

            UIView.animate(withDuration: duration, animations: { () -> Void in
                let xOffset : CGFloat = CGFloat(index) * self.controllerScrollView.frame.width
                self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
            })
        }
    }
}
