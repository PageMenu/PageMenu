//
//  ViewController.swift
//  PageMenuDemoSegmentedControl
//
//  Created by Niklas Fahl on 1/20/15.
//  Copyright (c) 2015 Niklas Fahl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "PAGE MENU"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        var controller1 : TestTableViewController = TestTableViewController(nibName: "TestTableViewController", bundle: nil)
        controller1.title = "FAVORITES"
        controllerArray.append(controller1)
        var controller2 : RecentsTableViewController = RecentsTableViewController(nibName: "RecentsTableViewController", bundle: nil)
        controller2.title = "RECENTS"
        controllerArray.append(controller2)
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray)
        
        // Set frame for scroll menu (set y origin to height of navbar if navbar is used and is transparent)
        pageMenu!.view.frame = CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height)
        
        // Customize menu (Optional)
        pageMenu!.scrollMenuBackgroundColor = UIColor.whiteColor()
        pageMenu!.viewBackgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        pageMenu!.bottomMenuHairlineColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1)
        pageMenu!.selectionIndicatorColor = UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        pageMenu!.menuMargin = 20.0
        pageMenu!.menuItemFont = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        pageMenu!.menuHeight = 44.0
        pageMenu!.selectionIndicatorHeight = 2.0
        pageMenu!.selectedMenuItemLabelColor = UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        pageMenu!.unselectedMenuItemLabelColor = UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)
        pageMenu!.useMenuLikeSegmentedControl = true
        pageMenu!.menuItemSeparatorWidth = 4.3
        pageMenu!.menuItemSeparatorPercentageHeight = 0.1
        pageMenu!.menuItemSeparatorRoundEdges = true
        
        self.view.addSubview(pageMenu!.view)
    }
}

