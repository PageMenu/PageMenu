//
//  ViewController.swift
//  PageMenuDemoSegmentedControl
//
//  Created by Niklas Fahl on 1/20/15.
//  Copyright (c) 2015 Niklas Fahl. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CAPSPageMenuDelegate {
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "PAGE MENU"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        var controller1 : TestTableViewController = TestTableViewController(nibName: "TestTableViewController", bundle: nil)
        controller1.parentNavigationController = self.navigationController
        controller1.title = "FAVORITES"
        controllerArray.append(controller1)
        
        var controller2 : RecentsTableViewController = RecentsTableViewController(nibName: "RecentsTableViewController", bundle: nil)
        controller2.title = "RECENTS"
        controller2.parentNavigationController = self.navigationController
        controllerArray.append(controller2)
        
        var controller3 : RecentsTableViewController = RecentsTableViewController(nibName: "RecentsTableViewController", bundle: nil)
        controller3.title = "FRIENDS"
        controller3.parentNavigationController = self.navigationController
        controllerArray.append(controller3)
        
        var controller4 : RecentsTableViewController = RecentsTableViewController(nibName: "RecentsTableViewController", bundle: nil)
        controller4.title = "OTHERS"
        controller4.parentNavigationController = self.navigationController
        controllerArray.append(controller4)
        
        // Customize menu (Optional)
        var parameters: [CAPSPageMenuOption] = [
            .MenuItemSeparatorWidth(4.3),
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .ViewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .BottomMenuHairlineColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1)),
            .SelectionIndicatorColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .MenuMargin(20.0),
            .MenuHeight(40.0),
            .SelectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .UnselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
            .MenuItemFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorRoundEdges(true),
            .SelectionIndicatorHeight(2.0),
            .MenuItemSeparatorPercentageHeight(0.1)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        // Optional delegate 
        pageMenu!.delegate = self
        
        self.view.addSubview(pageMenu!.view)
    }

    // Uncomment below for some navbar color animation fun using the new delegate functions
    
    func didMoveToPage(controller: UIViewController, index: Int) {
        println("did move to page")
        
//        var color : UIColor = UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)
//        var navColor : UIColor = UIColor(red: 17.0/255.0, green: 64.0/255.0, blue: 107.0/255.0, alpha: 1.0)
//        
//        if index == 1 {
//            color = UIColor.orangeColor()
//            navColor = color
//        } else if index == 2 {
//            color = UIColor.grayColor()
//            navColor = color
//        } else if index == 3 {
//            color = UIColor.purpleColor()
//            navColor = color
//        }
//        
//        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.navigationController!.navigationBar.barTintColor = navColor
//        }) { (completed) -> Void in
//            println("did fade")
//        }
    }
    
    func willMoveToPage(controller: UIViewController, index: Int) {
        println("will move to page")
        
//        var color : UIColor = UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)
//        var navColor : UIColor = UIColor(red: 17.0/255.0, green: 64.0/255.0, blue: 107.0/255.0, alpha: 1.0)
//        
//        if index == 1 {
//            color = UIColor.orangeColor()
//            navColor = color
//        } else if index == 2 {
//            color = UIColor.grayColor()
//            navColor = color
//        } else if index == 3 {
//            color = UIColor.purpleColor()
//            navColor = color
//        }
//        
//        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.navigationController!.navigationBar.barTintColor = navColor
//        }) { (completed) -> Void in
//            println("did fade")
//        }
    }
}