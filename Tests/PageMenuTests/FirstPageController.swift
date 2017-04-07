//
//  FirstPageController.swift
//  PageMenuTests
//
//  Created by Grayson Webster on 3/31/17.
//  Copyright © 2017 UACAPS. All rights reserved.
//

import UIKit

class FirstPageController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.green
        let view2 = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/2, height: 100))
        view2.backgroundColor = UIColor.blue
        view.addSubview(view2)
        print("Green loaded")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Green disappeared")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
