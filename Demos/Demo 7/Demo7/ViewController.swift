//
//  ViewController.swift
//  Demo7
//
//  Created by Atakishiyev Orazdurdy on 10/25/16.
//  Copyright © 2016 Veriloft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CAPSPageMenuDelegate, CMSteppedProgressBarDelegate {
    
    var pageMenu : CAPSPageMenu?
    var steppedBar : CMSteppedProgressBar!
    
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
            .scrollMenuBackgroundColor(UIColor.white),
            .viewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .selectionIndicatorHeight(20.0),
            .menuHeight(45.0),
            .menuItemSeparatorWidth(0),
            .addBottomMenuHairline(false),
            .selectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .unselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
            .menuItemFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorRoundEdges(true),
            .centerMenuItems(true),
            .showStepperView(true)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x:0.0, y:0.0, width:self.view.frame.width, height:self.view.frame.height), pageMenuOptions: parameters)
        
        //setup stepperBar
        let frame = self.view.frame
        steppedBar = CMSteppedProgressBar(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
        steppedBar.barColor = UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)
        steppedBar.tintColor = UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        steppedBar.backgroundColor = UIColor.clear
        steppedBar.linesHeight = 2
        steppedBar.dotsWidth = 10
        steppedBar.delegate = self
        steppedBar.numberOfSteps = UInt(controllerArray.count);
        pageMenu?.stepperView.addSubview(steppedBar)
        pageMenu?.controllerScrollView.isUserInteractionEnabled = false
        
        // Optional delegate
        pageMenu!.delegate = self
        
        self.view.addSubview(pageMenu!.view)
    }
    
    private func getIndicatorView()->UIView{
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 130))
        imgView.image = UIImage(named: "phone")
        return imgView
    }
    
    // Uncomment below for some navbar color animation fun using the new delegate functions
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        print("did move to page")
    }
    
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        print("will move to page")
        steppedBar.currentStep = UInt(index)
    }
    
    func steppedBar(_ steppedBar: CMSteppedProgressBar!, didSelect index: UInt) {
        pageMenu?.moveToPage(Int(index))
    }
}
