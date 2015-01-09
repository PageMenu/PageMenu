//
//  PageMenuTwoViewController.swift
//  PageMenuDemoTabbar
//
//  Created by Niklas Fahl on 1/9/15.
//  Copyright (c) 2015 Niklas Fahl. All rights reserved.
//

import UIKit

class PageMenuTwoViewController: UIViewController {
    
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // MARK: - UI Setup
        
//        self.title = "PAGE MENU"
//        self.navigationController?.navigationBar.barTintColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]
        
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        var controller1 : TestTableViewController = TestTableViewController(nibName: "TestTableViewController", bundle: nil)
        controller1.title = "friends"
        controllerArray.append(controller1)
        var controller2 : TestCollectionViewController = TestCollectionViewController(nibName: "TestCollectionViewController", bundle: nil)
        controller2.title = "mood"
        controllerArray.append(controller2)
        var controller3 : TestCollectionViewController = TestCollectionViewController(nibName: "TestCollectionViewController", bundle: nil)
        controller3.title = "favorites"
        controllerArray.append(controller3)
        var controller4 : TestTableViewController = TestTableViewController(nibName: "TestTableViewController", bundle: nil)
        controller4.title = "music"
        controllerArray.append(controller4)
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray)
        
        // Set frame for scroll menu (set y origin to height of navbar if navbar is used and is transparent)
        println("\(self.view.frame.width) \(self.view.frame.height)")
        pageMenu!.view.frame = CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height)
        
        // Customize menu (Optional)
        pageMenu!.scrollMenuBackgroundColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        pageMenu!.viewBackgroundColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        pageMenu!.selectionIndicatorColor = UIColor.orangeColor()
        pageMenu!.addBottomMenuHairline = false
        pageMenu!.menuItemFont = UIFont(name: "HelveticaNeue", size: 35.0)!
        pageMenu!.menuHeight = 50.0
        pageMenu!.selectionIndicatorHeight = 0.0
        pageMenu!.menuItemWidthBasedOnTitleTextWidth = true
        pageMenu!.selectedMenuItemLabelColor = UIColor.orangeColor()
        
        self.view.addSubview(pageMenu!.view)
    }
}
