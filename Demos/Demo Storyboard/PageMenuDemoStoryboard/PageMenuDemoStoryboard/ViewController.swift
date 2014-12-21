//
//  ViewController.swift
//  PageMenuDemoStoryboard
//
//  Created by Niklas Fahl on 12/19/14.
//  Copyright (c) 2014 CAPS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var pageMenu : CAPSPageMenu?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // MARK: - UI Setup
        
        self.title = "PAGE MENU"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]
        
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        var controller1 : TestTableViewController = TestTableViewController(nibName: "TestTableViewController", bundle: nil)
        controller1.title = "FRIENDS"
        controllerArray.append(controller1)
        var controller2 : TestCollectionViewController = TestCollectionViewController(nibName: "TestCollectionViewController", bundle: nil)
        controller2.title = "MOOD"
        controllerArray.append(controller2)
        var controller3 : TestViewController = TestViewController(nibName: "TestViewController", bundle: nil)
        controller3.title = "MUSIC"
        controllerArray.append(controller3)
        var controller4 : TestViewController = TestViewController(nibName: "TestViewController", bundle: nil)
        controller4.title = "FAVORITES"
        controllerArray.append(controller4)
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray)
        
        // Set frame for scroll menu (set y origin to height of navbar if navbar is used and is transparent)
        pageMenu!.view.frame = CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height)
        
        // Customize menu (Optional)
        pageMenu!.scrollMenuBackgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        pageMenu!.viewBackgroundColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
        pageMenu!.selectionIndicatorColor = UIColor.orangeColor()
        pageMenu!.bottomMenuHairlineColor = UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        pageMenu!.menuItemFont = UIFont(name: "HelveticaNeue", size: 13.0)!
        pageMenu!.menuHeight = 40.0
        
        self.view.addSubview(pageMenu!.view)
    }
}


