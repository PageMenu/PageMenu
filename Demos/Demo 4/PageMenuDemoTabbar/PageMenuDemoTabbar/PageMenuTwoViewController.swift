//
//  PageMenuTwoViewController.swift
//  PageMenuDemoTabbar
//
//  Created by Niklas Fahl on 1/9/15.
//  Copyright (c) 2015 Niklas Fahl. All rights reserved.
//

import UIKit
import PageMenu

class PageMenuTwoViewController: UIViewController {
    
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        let controller1 : TestTableViewController = TestTableViewController(nibName: "TestTableViewController", bundle: nil)
        controller1.title = "friends"
        controllerArray.append(controller1)
        let controller2 : TestCollectionViewController = TestCollectionViewController(nibName: "TestCollectionViewController", bundle: nil)
        controller2.title = "mood"
        controllerArray.append(controller2)
        let controller3 : TestCollectionViewController = TestCollectionViewController(nibName: "TestCollectionViewController", bundle: nil)
        controller3.title = "favorites"
        controllerArray.append(controller3)
        let controller4 : TestTableViewController = TestTableViewController(nibName: "TestTableViewController", bundle: nil)
        controller4.title = "music"
        controllerArray.append(controller4)
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)),
            .viewBackgroundColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)),
            .selectionIndicatorColor(UIColor.orange),
            .addBottomMenuHairline(false),
            .menuItemFont(UIFont(name: "HelveticaNeue", size: 35.0)!),
            .menuHeight(50.0),
            .selectionIndicatorHeight(0.0),
            .menuItemWidthBasedOnTitleTextWidth(true),
            .selectedMenuItemLabelColor(UIColor.orange)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 60.0, width: self.view.frame.width, height: self.view.frame.height - 60.0), pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
    }
}
