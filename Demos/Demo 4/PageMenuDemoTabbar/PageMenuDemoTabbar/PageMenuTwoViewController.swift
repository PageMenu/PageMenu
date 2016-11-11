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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        // Customize menu (Optional)
        var parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)),
            .ViewBackgroundColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)),
            .SelectionIndicatorColor(UIColor.orangeColor()),
            .AddBottomMenuHairline(false),
            .MenuItemFont(UIFont(name: "HelveticaNeue", size: 35.0)!),
            .MenuHeight(50.0),
            .SelectionIndicatorHeight(0.0),
            .MenuItemWidthBasedOnTitleTextWidth(true),
            .SelectedMenuItemLabelColor(UIColor.orangeColor())
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 60.0, self.view.frame.width, self.view.frame.height - 60.0), pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
    }
}
