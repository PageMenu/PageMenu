//
//  TestTableViewController.swift
//  NFTopMenuController
//
//  Created by Niklas Fahl on 12/17/14.
//  Copyright (c) 2014 Niklas Fahl. All rights reserved.
//

import UIKit

class TestTableViewController: UITableViewController {
    
    var namesArray : [String] = ["David Fletcher", "Charles Gray", "Timothy Jones", "Marie Turner", "Kim White"]
    var photoNameArray : [String] = ["man8.jpg", "man2.jpg", "man3.jpg", "woman4.jpg", "woman1.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendTableViewCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("favorites page: viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.showsVerticalScrollIndicator = false
        super.viewDidAppear(animated)
        self.tableView.showsVerticalScrollIndicator = true
        
//        println("favorites page: viewDidAppear")
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
        return namesArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : FriendTableViewCell = tableView.dequeueReusableCellWithIdentifier("FriendTableViewCell") as! FriendTableViewCell

        // Configure the cell...
        cell.nameLabel.text = namesArray[indexPath.row]
        cell.photoImageView.image = UIImage(named: photoNameArray[indexPath.row])

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 94.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

}