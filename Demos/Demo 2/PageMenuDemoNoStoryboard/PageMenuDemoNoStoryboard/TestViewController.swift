//
//  TestViewController.swift
//  PageMenuDemoNoStoryboard
//
//  Created by Niklas Fahl on 12/19/14.
//  Copyright (c) 2014 CAPS. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    var pageMenu : CAPSPageMenu?
    var pageMenu1 : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        var controller1 : UIViewController = UIViewController()
        controller1.view.backgroundColor = UIColor.purpleColor()
        controller1.title = "PURPLE"
        controllerArray.append(controller1)
        
        var controller2 : UIViewController = UIViewController()
        controller2.view.backgroundColor = UIColor.orangeColor()
        controller2.title = "ORANGE"
        controllerArray.append(controller2)
        
        var controller3 : UIViewController = UIViewController()
        controller3.view.backgroundColor = UIColor.grayColor()
        controller3.title = "GRAY"
        controllerArray.append(controller3)
        
        var controller4 : UIViewController = UIViewController()
        controller4.view.backgroundColor = UIColor.brownColor()
        controller4.title = "BROWN"
        controllerArray.append(controller4)
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 50.0, self.view.frame.width, 100), pageMenuOptions: nil)
        
        println(self.view.frame.height)
        
        self.view.addSubview(pageMenu!.view)
        
        // Initialize view controllers to display and place in array
        var controllerArray_1 : [UIViewController] = []
        
        var controller1_1 : UIViewController = UIViewController()
        controller1_1.view.backgroundColor = UIColor.brownColor()
        controller1_1.title = "BROWN"
        controllerArray_1.append(controller1_1)
        
        var controller2_1 : UIViewController = UIViewController()
        controller2_1.view.backgroundColor = UIColor.grayColor()
        controller2_1.title = "GRAY"
        controllerArray_1.append(controller2_1)
        
        var controller3_1 : UIViewController = UIViewController()
        controller3_1.view.backgroundColor = UIColor.orangeColor()
        controller3_1.title = "ORANGE"
        controllerArray_1.append(controller3_1)
        
        var controller4_1 : UIViewController = UIViewController()
        controller4_1.view.backgroundColor = UIColor.purpleColor()
        controller4_1.title = "PURPLE"
        controllerArray_1.append(controller4_1)
        
        // Initialize scroll menu
        pageMenu1 = CAPSPageMenu(viewControllers: controllerArray_1, frame: CGRectMake(0.0, 400.0, self.view.frame.width, 100.0), pageMenuOptions: nil)
        
        self.view.addSubview(pageMenu1!.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
