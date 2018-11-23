//
//  TestTableViewController.m
//  PageMenuDemoStoryboard
//
//  Created by Jin Sasaki on 2015/06/05.
//  Copyright (c) 2015年 Jin Sasaki. All rights reserved.
//

#import "TestTableViewController.h"

@interface TestTableViewController ()
@property (nonatomic) NSArray *namesArray;
@property (nonatomic) NSArray *photoNameArray;
@end

@implementation TestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.namesArray = @[@"Lauren Richard", @"Nicholas Ray", @"Kim White", @"Charles Gray", @"Timothy Jones", @"Sarah Underwood", @"William Pearl", @"Juan Rodriguez", @"Anna Hunt", @"Marie Turner", @"George Porter", @"Zachary Hecker", @"David Fletcher"];
    self.photoNameArray= @[@"woman5.jpg", @"man1.jpg", @"woman1.jpg", @"man2.jpg", @"man3.jpg", @"woman2.jpg", @"man4.jpg", @"man5.jpg", @"woman3.jpg", @"woman4.jpg", @"man6.jpg", @"man7.jpg", @"man8.jpg"];

    [self.tableView registerNib:[UINib nibWithNibName:@"FriendTableViewCell" bundle:nil] forCellReuseIdentifier:@"FriendTableViewCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 13;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.nameLabel.text = self.namesArray[indexPath.row];
    cell.photoImageView.image = [UIImage imageNamed:self.photoNameArray[indexPath.row]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}
@end
