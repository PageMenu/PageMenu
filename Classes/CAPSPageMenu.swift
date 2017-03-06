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

open class CAPSPageMenu: UIViewController {

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

    public var currentPageIndex : Int = 0
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
    public init(viewControllers: [UIViewController], in controller: UIViewController, with configuration: CAPSPageMenuConfiguration, usingStoryboards: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.configuration = configuration
        controllerArray = viewControllers
        
        //Setup storyboard
        self.view.frame = CGRect(x: 0, y: 0, width: controller.view.frame.size.width, height: controller.view.frame.size.height)
        if usingStoryboards {
            controller.addChildViewController(self)
            controller.view.addSubview(self.view)
            didMove(toParentViewController: controller)
        }
        else {
            controller.view.addSubview(self.view)
        }
        
        
        //Build UI
        setUpUserInterface()
        if menuScrollView.subviews.count == 0 {
            configureUserInterface()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}



extension CAPSPageMenu {    
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
