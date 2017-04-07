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
        let third = FirstPageController()
        let fourth = SecondPageController()
//        let fifth = FirstPageController()
//        let sixth = SecondPageController()
//        let seventh = FirstPageController()
//        let eigth = SecondPageController()
//        let ninth = FirstPageController()
//        let tenth = SecondPageController()
//        let eleventh = FirstPageController()
        addPage(first, title: "Green")
        addPage(second, title: "Red")
        addPage(third, title: "Green2")
        addPage(fourth, title: "Red2")
//        addPage(fifth, title: "Green3")
//        addPage(sixth, title: "Red3")
//        addPage(seventh, title: "Green4")
//        addPage(eigth, title: "Red4")
//        addPage(ninth, title: "Green5")
//        addPage(tenth, title: "Red5")
//        addPage(eleventh, title: "Green6")
        pageMenuBar.buttonItems.forEach { $0.setTitleColor(UIColor.green, for: .normal) }
        pageMenuBar.setAlignment(alignment: .fit)
        pageMenuBar.setSpacing(10, 40, 0, 40)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

