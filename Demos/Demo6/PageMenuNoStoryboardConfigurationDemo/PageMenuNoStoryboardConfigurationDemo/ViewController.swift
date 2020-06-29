//
//  ViewController.swift
//  PageMenuNoStoryboardConfigurationDemo
//
//  Created by Matthew York on 3/6/17.
//  Copyright © 2017 UACAPS. All rights reserved.
//

import UIKit
import PageMenu

class ViewController: UIViewController {

    var pageMenu: CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPageMenu()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupPageMenu() {
        //Create controllers
        let colors = [UIColor.black, UIColor.blue, UIColor.red, UIColor.gray, UIColor.green, UIColor.purple, UIColor.orange, UIColor.brown, UIColor.cyan]
        let controllers = colors.map { (color: UIColor) -> UIViewController in
            let controller = UIViewController()
            controller.view.backgroundColor = color
            return controller
        }
        
        //Create page menu
        self.pageMenu = CAPSPageMenu(viewControllers: controllers, in: self, with: dummyConfiguration())
    }
    
    func dummyConfiguration() -> CAPSPageMenuConfiguration {
        let configuration = CAPSPageMenuConfiguration()
        
        return configuration
    }
}
