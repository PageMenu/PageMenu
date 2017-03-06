//
//  TestViewController.swift
//  PageMenuDemoNoStoryboard
//
//  Created by Niklas Fahl on 12/19/14.
//  Copyright (c) 2014 CAPS. All rights reserved.
//

import UIKit
import PageMenu

class TestViewController: UIViewController {
    
    var pageMenu : CAPSPageMenu?
    var pageMenu1 : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        let controller1 : UIViewController = UIViewController()
        controller1.view.backgroundColor = UIColor.purple
        controller1.title = "PURPLE"
        controllerArray.append(controller1)
        
        let controller2 : UIViewController = UIViewController()
        controller2.view.backgroundColor = UIColor.orange
        controller2.title = "ORANGE"
        controllerArray.append(controller2)
        
        let controller3 : UIViewController = UIViewController()
        controller3.view.backgroundColor = UIColor.gray
        controller3.title = "GRAY"
        controllerArray.append(controller3)
        
        let controller4 : UIViewController = UIViewController()
        controller4.view.backgroundColor = UIColor.brown
        controller4.title = "BROWN"
        controllerArray.append(controller4)
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 50.0, width: self.view.frame.width, height: 100), pageMenuOptions: nil)
        
        print(self.view.frame.height)
        
        self.view.addSubview(pageMenu!.view)
        
        // Initialize view controllers to display and place in array
        var controllerArray_1 : [UIViewController] = []
        
        let controller1_1 : UIViewController = UIViewController()
        controller1_1.view.backgroundColor = UIColor.brown
        controller1_1.title = "BROWN"
        controllerArray_1.append(controller1_1)
        
        let controller2_1 : UIViewController = UIViewController()
        controller2_1.view.backgroundColor = UIColor.gray
        controller2_1.title = "GRAY"
        controllerArray_1.append(controller2_1)
        
        let controller3_1 : UIViewController = UIViewController()
        controller3_1.view.backgroundColor = UIColor.orange
        controller3_1.title = "ORANGE"
        controllerArray_1.append(controller3_1)
        
        let controller4_1 : UIViewController = UIViewController()
        controller4_1.view.backgroundColor = UIColor.purple
        controller4_1.title = "PURPLE"
        controllerArray_1.append(controller4_1)
        
        // Initialize scroll menu
        pageMenu1 = CAPSPageMenu(viewControllers: controllerArray_1, frame: CGRect(x: 0.0, y: 400.0, width: self.view.frame.width, height: 100.0), pageMenuOptions: nil)
        
        self.view.addSubview(pageMenu1!.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
