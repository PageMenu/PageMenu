//
//  RecentsTableViewController.swift
//  PageMenuDemoTabbar
//
//  Created by Niklas Fahl on 1/9/15.
//  Copyright (c) 2015 Niklas Fahl. All rights reserved.
//

import UIKit

class RecentsTableViewController: UITableViewController {
    
    var parentNavigationController : UINavigationController?
        
    var namesArray : [String] = ["Kim White", "Kim White", "David Fletcher", "Anna Hunt", "Timothy Jones", "Timothy Jones", "Timothy Jones", "Lauren Richard", "Lauren Richard", "Juan Rodriguez"]
    var photoNameArray : [String] = ["woman1.jpg", "woman1.jpg", "man8.jpg", "woman3.jpg", "man3.jpg", "man3.jpg", "man3.jpg", "woman5.jpg", "woman5.jpg", "man5.jpg"]
    var activityTypeArray : NSArray = [0, 1, 1, 0, 2, 1, 2, 0, 0, 2]
    var dateArray : NSArray = ["4:22 PM", "Wednesday", "Tuesday", "Sunday", "01/02/15", "12/31/14", "12/28/14", "12/24/14", "12/17/14", "12/14/14"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "RecentsTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentsTableViewCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("\(self.title) page: viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.showsVerticalScrollIndicator = false
        super.viewDidAppear(animated)
        self.tableView.showsVerticalScrollIndicator = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : RecentsTableViewCell = tableView.dequeueReusableCellWithIdentifier("RecentsTableViewCell") as! RecentsTableViewCell
        
        // Configure the cell...
        cell.nameLabel.text = namesArray[indexPath.row]
        cell.photoImageView.image = UIImage(named: photoNameArray[indexPath.row])
        cell.dateLabel.text = dateArray[indexPath.row] as! NSString as String
        cell.nameLabel.textColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        
        if activityTypeArray[indexPath.row] as! Int == 0 {
            cell.activityImageView.image = UIImage(named: "phone_send")
        } else if activityTypeArray[indexPath.row] as! Int == 1 {
            cell.activityImageView.image = UIImage(named: "phone_receive")
        } else {
            cell.activityImageView.image = UIImage(named: "phone_down")
            cell.nameLabel.textColor = UIColor.redColor()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 94.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var newVC : UIViewController = UIViewController()
        newVC.view.backgroundColor = UIColor.whiteColor()
        newVC.title = "Favorites"
        
        parentNavigationController!.pushViewController(newVC, animated: true)
    }
    
}
