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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray)
        
        // Set frame for scroll menu (set y origin to height of navbar if navbar is used and is transparent)
        pageMenu!.view.frame = CGRectMake(0.0, 60.0, self.view.frame.width, self.view.frame.height - 60.0)
        
        // Customize menu (Optional)
        pageMenu!.scrollMenuBackgroundColor = UIColor.orangeColor()
        pageMenu!.viewBackgroundColor = UIColor.whiteColor()
        pageMenu!.bottomMenuHairlineColor = UIColor.orangeColor()
        pageMenu!.selectionIndicatorColor = UIColor.whiteColor()
        pageMenu!.menuMargin = 20.0
        pageMenu!.menuItemFont = UIFont(name: "HelveticaNeue", size: 35.0)!
        pageMenu!.menuHeight = 44.0
        pageMenu!.selectionIndicatorHeight = 0.0
        pageMenu!.menuItemWidthBasedOnTitleTextWidth = true
        pageMenu!.selectedMenuItemLabelColor = UIColor.whiteColor()
        pageMenu!.unselectedMenuItemLabelColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.4)
        
        self.view.addSubview(pageMenu!.view)
    }
    
    func getRandomColor() -> UIColor{
        
        var randomRed:CGFloat = CGFloat(drand48())
        
        var randomGreen:CGFloat = CGFloat(drand48())
        
        var randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
}
