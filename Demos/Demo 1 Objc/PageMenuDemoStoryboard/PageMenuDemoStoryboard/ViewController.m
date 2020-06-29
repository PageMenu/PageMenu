//
//  ViewController.m
//  PageMenuDemoStoryboard
//
//  Created by Jin Sasaki on 2015/06/05.
//  Copyright (c) 2015年 Jin Sasaki. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@property (nonatomic) CAPSPageMenu *pageMenu;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"PAGE MENU";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor orangeColor]};
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"<-" style:UIBarButtonItemStyleDone target:self action:@selector(didTapGoToLeft)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"->" style:UIBarButtonItemStyleDone target:self action:@selector(didTapGoToRight)];
    
    TestTableViewController *controller1 = [[TestTableViewController alloc]initWithNibName:@"TestTableViewController" bundle:nil];
    controller1.title = @"FRIENDS";
    TestCollectionViewController *controller2 = [[TestCollectionViewController alloc]initWithNibName:@"TestCollectionViewController" bundle:nil];
    controller2.title = @"MOOD";
    TestViewController *controller3 = [[TestViewController alloc] initWithNibName:@"TestViewController" bundle:nil];
    controller3.title = @"MUSIC";
    TestViewController *controller4 = [[TestViewController alloc] initWithNibName:@"TestViewController" bundle:nil];
    controller4.title = @"FAVORITES";

    NSArray *controllerArray = @[controller1, controller2, controller3, controller4];
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor orangeColor],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:13.0],
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(90.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES)
                                 };

    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    [self.view addSubview:_pageMenu.view];
}

- (void)didTapGoToLeft {
    NSInteger currentIndex = self.pageMenu.currentPageIndex;
    
    if (currentIndex > 0) {
        [_pageMenu moveToPage:currentIndex - 1];
    }
}

- (void)didTapGoToRight {
    NSInteger currentIndex = self.pageMenu.currentPageIndex;
    
    if (currentIndex < self.pageMenu.controllerArray.count) {
        [self.pageMenu moveToPage:currentIndex + 1];
    }
}

@end
