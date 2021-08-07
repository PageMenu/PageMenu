//
//  ViewController.swift
//  PageMenuDemoSegmentedControl
//
//  Created by Niklas Fahl on 1/20/15.
//  Copyright (c) 2015 Niklas Fahl. All rights reserved.
//

import UIKit
import PageMenu

class ViewController: UIViewController, CAPSPageMenuDelegate {
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "PAGE MENU"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        let controller1 : TestTableViewController = TestTableViewController(nibName: "TestTableViewController", bundle: nil)
        controller1.parentNavigationController = self.navigationController
        controller1.title = "FAVORITES"
        controllerArray.append(controller1)
        
        let controller2 : RecentsTableViewController = RecentsTableViewController(nibName: "RecentsTableViewController", bundle: nil)
        controller2.title = "RECENTS"
        controller2.parentNavigationController = self.navigationController
        controllerArray.append(controller2)
        
        let controller3 : RecentsTableViewController = RecentsTableViewController(nibName: "RecentsTableViewController", bundle: nil)
        controller3.title = "FRIENDS"
        controller3.parentNavigationController = self.navigationController
        controllerArray.append(controller3)
        
        let controller4 : RecentsTableViewController = RecentsTableViewController(nibName: "RecentsTableViewController", bundle: nil)
        controller4.title = "OTHERS"
        controller4.parentNavigationController = self.navigationController
        controllerArray.append(controller4)
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(4.3),
            .scrollMenuBackgroundColor(UIColor.white),
            .viewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .bottomMenuHairlineColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1)),
            .selectionIndicatorColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .menuMargin(20.0),
            .menuHeight(40.0),
            .selectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .unselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
            .menuItemFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorRoundEdges(true),
            .selectionIndicatorHeight(2.0),
            .menuItemSeparatorPercentageHeight(0.1)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
        
        // Optional delegate 
        pageMenu!.delegate = self
        
        self.view.addSubview(pageMenu!.view)
    }

    // Uncomment below for some navbar color animation fun using the new delegate functions
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        print("did move to page")
        
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
    
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        print("will move to page")
        
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
