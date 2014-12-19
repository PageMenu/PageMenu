//
//  NFScrollMenuViewController.swift
//  NFTopMenuController
//
//  Created by Niklas Fahl on 12/16/14.
//  Copyright (c) 2014 Niklas Fahl. All rights reserved.
//

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
    
    var menuHeight : CGFloat = 34.0
    var menuMargin : CGFloat = 15.0
    var menuItemWidth : CGFloat = 111.0
    var selectionIndicatorHeight : CGFloat = 3.0
    
    var selectionIndicatorView : UIView = UIView()
    
    var currentPageIndex : Int = 0
    var lastPageIndex : Int = 0
    
    var selectionIndicatorColor : UIColor = UIColor.whiteColor()
    var selectedMenuItemLabelColor : UIColor = UIColor.whiteColor()
    var unselectedMenuItemLabelColor : UIColor = UIColor.lightGrayColor()
    var scrollMenuBackgroundColor : UIColor = UIColor.blackColor()
    var viewBackgroundColor : UIColor = UIColor.whiteColor()
    var bottomMenuHairlineColor : UIColor = UIColor.whiteColor()
    
    var menuItemFont : UIFont?
    
    var addBottomMenuHairline : Bool = true
    
    
    // MARK: - View life cycle
    
    init(viewControllers: [AnyObject]) {
        super.init()
        
        controllerArray = viewControllers
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpUserInterface()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - UI Setup
    
    func setUpUserInterface() {
        // Set background color behind scroll views
        self.view.backgroundColor = viewBackgroundColor
        
        // Add tap gesture recognizer to controller scroll view to recognize menu item selection
        let menuItemTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleMenuItemTap:"))
        menuItemTapGestureRecognizer.numberOfTapsRequired = 1
        menuItemTapGestureRecognizer.numberOfTouchesRequired = 1
        menuItemTapGestureRecognizer.delegate = self
        controllerScrollView.addGestureRecognizer(menuItemTapGestureRecognizer)
        
        // Set delegate for controller scroll view
        controllerScrollView.delegate = self
        
        // Set up menu scroll view content size and background color for menu scroll view
        menuScrollView.contentSize = CGSizeMake((menuItemWidth + menuMargin) * CGFloat(controllerArray.count) + menuMargin, menuScrollView.frame.height)
        menuScrollView.backgroundColor = scrollMenuBackgroundColor
        
        // Set up controller scroll view
        controllerScrollView.contentSize = CGSizeMake(controllerScrollView.frame.width * CGFloat(controllerArray.count), controllerScrollView.frame.height)
        
        var index : CGFloat = 0.0
        
        for controller in controllerArray {
            if controller.isKindOfClass(UIViewController) {
                (controller as UIViewController).view.frame = CGRectMake(controllerScrollView.frame.width * index, menuScrollView.frame.height, controllerScrollView.frame.width, controllerScrollView.frame.height - menuScrollView.frame.height)
                
                controllerScrollView.addSubview((controller as UIViewController).view)
                
                // Set up menu item for menu scroll view
                var menuItemView : MenuItemView = MenuItemView(frame: CGRectMake(menuItemWidth * index + menuMargin * (index + 1), 0.0, menuItemWidth, menuScrollView.frame.height))
                menuItemView.setUpMenuItemView(menuItemWidth, menuScrollViewHeight: menuScrollView.frame.height, indicatorHeight: selectionIndicatorHeight)
                
                if menuItemFont != nil {
                    menuItemView.titleLabel!.font = menuItemFont
                }
                menuItemView.titleLabel!.textAlignment = NSTextAlignment.Center
                menuItemView.titleLabel!.textColor = unselectedMenuItemLabelColor
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
        
        // Set selected color for title label of selected menu item
        if menuItems[currentPageIndex].titleLabel != nil {
            menuItems[currentPageIndex].titleLabel!.textColor = selectedMenuItemLabelColor
        }
        
        // Add hairline to menu scroll view
        if addBottomMenuHairline {
            var menuBottomHairline : UIView = UIView(frame: CGRectMake(-150.0, menuScrollView.frame.height - 0.5, menuScrollView.contentSize.width + 300.0, 0.5))
            menuBottomHairline.backgroundColor = bottomMenuHairlineColor
            menuScrollView.addSubview(menuBottomHairline)
        }
        
        // Set up selection indicator view
        selectionIndicatorView = UIView(frame: CGRectMake(menuMargin, menuScrollView.frame.height - selectionIndicatorHeight, menuItemWidth, selectionIndicatorHeight))
        selectionIndicatorView.backgroundColor = selectionIndicatorColor
        menuScrollView.addSubview(selectionIndicatorView)
    }
    
    
    // MARK: - Scroll view delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var ratio : CGFloat = 1.0
        
        if scrollView.isEqual(controllerScrollView) {
            // Calculate ratio between scroll views
            ratio = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
            
            if menuScrollView.contentSize.width > self.view.frame.width {
                var offset : CGPoint = menuScrollView.contentOffset
                offset.x = controllerScrollView.contentOffset.x * ratio
                menuScrollView.setContentOffset(offset, animated: false)
            }
            
            // Calculate current page
            var width : CGFloat = scrollView.frame.size.width;
            var page : Int = Int((scrollView.contentOffset.x + (0.5 * width)) / width)
            
            // Update page if changed
            if page != currentPageIndex {
                lastPageIndex = currentPageIndex
                currentPageIndex = page
            }
            
            // Move selection indicator view when swiping
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.selectionIndicatorView.frame = CGRectMake((self.menuMargin + self.menuItemWidth) * CGFloat(page) + self.menuMargin, self.selectionIndicatorView.frame.origin.y, self.selectionIndicatorView.frame.width, self.selectionIndicatorView.frame.height)
                
                // Switch newly selected menu item title label to selected color and old one to unselected color
                if self.menuItems[self.lastPageIndex].titleLabel != nil && self.menuItems[self.currentPageIndex].titleLabel != nil {
                    self.menuItems[self.lastPageIndex].titleLabel!.textColor = self.unselectedMenuItemLabelColor
                    self.menuItems[self.currentPageIndex].titleLabel!.textColor = self.selectedMenuItemLabelColor
                }
            })
        }
    }
    
    
    // MARK: - Tap gesture recognizer selector
    
    func handleMenuItemTap(gestureRecognizer : UITapGestureRecognizer) {
        var tappedPoint : CGPoint = gestureRecognizer.locationInView(menuScrollView)
        
        if tappedPoint.y < menuScrollView.frame.height {
            
            // Calculate tapped page
            var itemIndex : Int = Int(tappedPoint.x / 141.0)
            
            // Update page if changed
            if itemIndex != currentPageIndex {
                lastPageIndex = currentPageIndex
                currentPageIndex = itemIndex
            }
            
            // Move selection indicator view when swiping
            UIView.animateWithDuration(0.7, animations: { () -> Void in
                var xOffset : CGFloat = CGFloat(itemIndex) * self.controllerScrollView.frame.width
                self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: true)
            })
        }
    }
}
