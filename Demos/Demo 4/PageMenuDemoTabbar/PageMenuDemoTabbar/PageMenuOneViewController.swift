//
//  PageMenuOneViewController.swift
//  PageMenuDemoTabbar
//
//  Created by Niklas Fahl on 1/9/15.
//  Copyright (c) 2015 Niklas Fahl. All rights reserved.
//

import UIKit
import PageMenu

class PageMenuOneViewController: UIViewController {
    
    var pageMenu : CAPSPageMenu?
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPhotoImageView.layer.cornerRadius = 8
        
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        let controller1 : TestTableViewController = TestTableViewController(nibName: "TestTableViewController", bundle: nil)
        controller1.title = "favorites"
        controllerArray.append(controller1)
        let controller2 : RecentsTableViewController = RecentsTableViewController(nibName: "RecentsTableViewController", bundle: nil)
        controller2.title = "recents"
        controllerArray.append(controller2)
        let controller3 : ContactsTableViewController = ContactsTableViewController(nibName: "ContactsTableViewController", bundle: nil)
        controller3.title = "contacts"
        controllerArray.append(controller3)
        
        for i in 0...10 {
            let controller3 : ContactsTableViewController = ContactsTableViewController(nibName: "ContactsTableViewController", bundle: nil)
            controller3.title = "contr\(i)"
            //            controller3.view.backgroundColor = getRandomColor()
            controllerArray.append(controller3)
        }
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.orange),
            .viewBackgroundColor(UIColor.white),
            .selectionIndicatorColor(UIColor.white),
            .unselectedMenuItemLabelColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.4)),
            .menuItemFont(UIFont(name: "HelveticaNeue", size: 35.0)!),
            .menuHeight(44.0),
            .menuMargin(20.0),
            .selectionIndicatorHeight(0.0),
            .bottomMenuHairlineColor(UIColor.orange),
            .menuItemWidthBasedOnTitleTextWidth(true),
            .selectedMenuItemLabelColor(UIColor.white)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 60.0, width: self.view.frame.width, height: self.view.frame.height - 60.0), pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
}
