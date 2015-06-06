//
//  PageMenuOneViewController.swift
//  PageMenuDemoTabbar
//
//  Created by Niklas Fahl on 1/9/15.
//  Copyright (c) 2015 Niklas Fahl. All rights reserved.
//

import UIKit

class PageMenuOneViewController: UIViewController {
    
    var pageMenu : CAPSPageMenu?
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPhotoImageView.layer.cornerRadius = 8
        
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        var controller1 : TestTableViewController = TestTableViewController(nibName: "TestTableViewController", bundle: nil)
        controller1.title = "favorites"
        controllerArray.append(controller1)
        var controller2 : RecentsTableViewController = RecentsTableViewController(nibName: "RecentsTableViewController", bundle: nil)
        controller2.title = "recents"
        controllerArray.append(controller2)
        var controller3 : ContactsTableViewController = ContactsTableViewController(nibName: "ContactsTableViewController", bundle: nil)
        controller3.title = "contacts"
        controllerArray.append(controller3)
        
        for i in 0...10 {
            var controller3 : ContactsTableViewController = ContactsTableViewController(nibName: "ContactsTableViewController", bundle: nil)
            controller3.title = "contr\(i)"
            //            controller3.view.backgroundColor = getRandomColor()
            controllerArray.append(controller3)
        }
        
        // Customize menu (Optional)
        var parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor.orangeColor()),
            .ViewBackgroundColor(UIColor.whiteColor()),
            .SelectionIndicatorColor(UIColor.whiteColor()),
            .UnselectedMenuItemLabelColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.4)),
            .MenuItemFont(UIFont(name: "HelveticaNeue", size: 35.0)!),
            .MenuHeight(44.0),
            .MenuMargin(20.0),
            .SelectionIndicatorHeight(0.0),
            .BottomMenuHairlineColor(UIColor.orangeColor()),
            .MenuItemWidthBasedOnTitleTextWidth(true),
            .SelectedMenuItemLabelColor(UIColor.whiteColor())
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 60.0, self.view.frame.width, self.view.frame.height - 60.0), pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
    }
    
    func getRandomColor() -> UIColor{
        
        var randomRed:CGFloat = CGFloat(drand48())
        
        var randomGreen:CGFloat = CGFloat(drand48())
        
        var randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
}
