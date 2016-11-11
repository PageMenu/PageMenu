//
//  ContactsTableViewController.swift
//  PageMenuDemoTabbar
//
//  Created by Niklas Fahl on 1/9/15.
//  Copyright (c) 2015 Niklas Fahl. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController {
    
    var namesArray : [String] = ["David Fletcher", "Charles Gray", "Zachary Hecker", "Anna Hunt", "Timothy Jones", "William Pearl", "George Porter", "Nicholas Ray", "Lauren Richard", "Juan Rodriguez", "Marie Turner", "Sarah Underwood", "Kim White"]
    var photoNameArray : [String] = ["man8.jpg", "man2.jpg", "man7.jpg", "woman3.jpg", "man3.jpg", "man4.jpg", "man1.jpg", "man6.jpg", "woman5.jpg", "man5.jpg", "woman4.jpg", "woman2.jpg", "woman1.jpg"]
    var staredArray : [Bool] = [true, true, false, false, true, false, false, false, false, false, true, false, true]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("\(self.title) page: viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
//        println("contacts page: viewDidAppear")
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
        return 13
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : ContactTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContactTableViewCell") as! ContactTableViewCell
        
        // Configure the cell...
        cell.nameLabel.text = namesArray[indexPath.row]
        cell.photoImageView.image = UIImage(named: photoNameArray[indexPath.row])
        
        if staredArray[indexPath.row] {
            cell.starButton.imageView?.image = UIImage(named: "stared")
        } else {
            cell.starButton.imageView?.image = UIImage(named: "unstared")
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
        println("did select contact row")
        let contactPrompt = UIAlertController(title: "Contact Selected", message: "You have selected a contact.", preferredStyle: UIAlertControllerStyle.Alert)
        contactPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(contactPrompt, animated: true, completion: nil)
    }
}
