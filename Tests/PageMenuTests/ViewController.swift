//
//  ViewController.swift
//  PageMenuTests
//
//  Created by Matthew York on 3/9/17.
//  Copyright © 2017 UACAPS. All rights reserved.
//

import UIKit
import PageMenu

class ViewController: PageMenuController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let first = FirstPageController()
        let second = SecondPageController()
        addPage(first, title: "Green")
        addPage(second, title: "Red")
        pageMenuBar.buttonItems.forEach { $0.setTitleColor(UIColor.blue, for: .normal) }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

