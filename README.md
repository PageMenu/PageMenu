<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuHeader3.png" alt="PageMenuHeader">
========

[![Version](https://img.shields.io/cocoapods/v/PageMenu.svg?style=flat)](http://cocoapods.org/pods/PageMenu)
[![License](https://img.shields.io/cocoapods/l/PageMenu.svg?style=flat)](http://cocoapods.org/pods/PageMenu)
[![Platform](https://img.shields.io/cocoapods/p/PageMenu.svg?style=flat)](http://cocoapods.org/pods/PageMenu)

**Objective-C version in Beta**

## Latest Update

**1.2.8 Release (06/22/2015)**
* Bug fixes
* Obj-c more stable


## Description

A fully customizable and flexible paging menu controller built from other view controllers placed inside a scroll view allowing the user to switch between any kind of view controller with an easy tap or swipe gesture similar to what Spotify, Windows Phone, and Instagram use

**Similar to Spotify**

<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuDemo.gif" alt="PageMenuDemo">
<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuScreen8.png" alt="PageMenuScreen2">

**Similar to Windows Phone**

<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuDemo2.gif" alt="PageMenuDemo2">
<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuScreen7.png" alt="PageMenuScreen2">

**Similar to Instagram segmented control**

<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuDemoSegmentedControlGif.gif" alt="PageMenuDemoSegmentedControlGif">
<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuDemoScreen6.png" alt="PageMenuDemoScreen6">

## Installation

**Cocoa Pods**

PageMenu is available through [CocoaPods](http://cocoapods.org). !! Swift only !!

To install add the following line to your Podfile:

    pod 'PageMenu'

**Manual Installation**

The class file required for PageMenu is located in the Classes folder in the root of this repository as listed below:

* CAPSPageMenu.swift

## How to use PageMenu

First you will have to create a view controller that is supposed to serve as the base of the page menu. This can be a view controller with its xib file as a separate file as well as having its xib file in storyboard. Following this you will have to go through a few simple steps outlined below in order to get everything up and running.

**1)  Add the files listed in the installation section to your project**

**2)  Add a property for CAPSPageMenu in your base view controller**

Swift

```swift
var pageMenu : CAPSPageMenu?
```

Objective-C

```objectivec
@property (nonatomic) CAPSPageMenu *pagemenu;
```

**3)  Add the following code in the viewDidLoad function in your view controller**

Swift

```swift
// Array to keep track of controllers in page menu
var controllerArray : [UIViewController] = []

// Create variables for all view controllers you want to put in the 
// page menu, initialize them, and add each to the controller array. 
// (Can be any UIViewController subclass)
// Make sure the title property of all view controllers is set
// Example:
var controller : UIViewController = UIViewController(nibName: "controllerNibName", bundle: nil)
controller.title = "SAMPLE TITLE"
controllerArray.append(controller)

// Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
// Example:
var parameters: [CAPSPageMenuOption] = [
    .MenuItemSeparatorWidth(4.3), 
    .UseMenuLikeSegmentedControl(true), 
    .MenuItemSeparatorPercentageHeight(0.1)
]

// Initialize page menu with controller array, frame, and optional parameters
pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)

// Lastly add page menu as subview of base view controller view
// or use pageMenu controller in you view hierachy as desired
self.view.addSubview(pageMenu!.view)
```

Objective-C

```objectivec
// Array to keep track of controllers in page menu
NSMutableArray *controllerArray = [NSMutableArray array];

// Create variables for all view controllers you want to put in the 
// page menu, initialize them, and add each to the controller array. 
// (Can be any UIViewController subclass)
// Make sure the title property of all view controllers is set
// Example:
UIViewController *controller = [UIViewController alloc] initWithNibname:@"controllerNibnName" bundle:nil];
controller.title = @"SAMPLE TITLE";
[controllerArray addObject:controller];

// Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
// Example:
NSDictionary *parameters = @{CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
                             CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                             CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.1)
                             };

// Initialize page menu with controller array, frame, and optional parameters
_pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];

// Lastly add page menu as subview of base view controller view
// or use pageMenu controller in you view hierachy as desired
[self.view addSubview:_pageMenu.view];
```

**4)  Optional - Delegate Methods**

In order to use the delegate methods first set the delegate of page menu to the parent view controller when setting it up

Swift

```swift
// Optional delegate 
pageMenu!.delegate = self
```

Objective-C

```objectivec
// Optional delegate 
_pageMenu.delegate = self;
```


After that you will be able to set up the following delegate methods inside of your parent view controller

Swift

```swift
func willMoveToPage(controller: UIViewController, index: Int){}

func didMoveToPage(controller: UIViewController, index: Int){}
```

Objective-C

```objectivec
// Optional delegate 
- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index {}

- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index {}
```

**5)  You should now be ready to use PageMenu!! 🎉**

## Customization

There are many ways you are able to customize page menu for your needs and there will be more customizations coming in the future to make sure page menu conforms to your app design. These will all be properties in CAPSPageMenu that can be changed from your base view controller. (Property names given with each item below)

**1)  Colors**

  * Background color behind the page menu scroll view to blend in view controller backgrounds 

        viewBackgroundColor (UIColor)

  * Scroll menu background color

        scrollMenuBackgroundColor (UIColor)


  * Selection indicator color

        selectionIndicatorColor (UIColor)


  * Selected menu item label color

        selectedMenuItemLabelColor (UIColor)


  * Unselected menu item label color

        unselectedMenuItemLabelColor (UIColor)


  * Menu item separator color (Used for segmented control style)

        menuItemSeparatorColor (UIColor)


  * Bottom menu hairline color

        bottomMenuHairlineColor (UIColor)



**2)  Dimensions**

  * Scroll menu height

        menuHeight (CGFloat)


  * Scroll menu margin (leading space before first menu item and after last menu item as well as in between items)

        menuMargin (CGFloat)


  * Scroll menu item width

        menuItemWidth (CGFloat)


  * Selection indicator height

        selectionIndicatorHeight (CGFloat)


**3)  Segmented Control**

  * Use PageMenu as segmented control

        useMenuLikeSegmentedControl (Bool)

   
  * Menu item separator width in pixels

        menuItemSeparatorWidth (CGFloat)


  * Menu item separator height in percentage of menu height

        menuItemSeparatorPercentageHeight (CGFloat)


  * Menu item separator has rounded edges

        menuItemSeparatorRoundEdges (Bool)


**4)  Others**
  * Menu item title label font

        menuItemFont (UIFont)


  * Bottom menu hairline

        addBottomMenuHairline (Bool)


  * Menu item witdh based on title text width (see Demo 3)

        menuItemWidthBasedOnTitleTextWidth (Bool)


  * Disable/Enable horizontal bounce for controller scroll view

        enableHorizontalBounce (Bool)


  * Hide/Unhide top menu bar

        hideTopMenuBar (Bool)


  * Center menu items in menu if they don't span entire width (Not currently supported for menu item width based on title)

        centerMenuItems (Bool)


  * Scroll animation duration on menu item tap in milliseconds

        scrollAnimationDurationOnMenuItemTap (Int)

## Apps using PageMenu

Please let me know if your app in the AppStore uses this library so I can add your app to this list.

* [Alabama MVD](http://bit.ly/AlabamaMVD) by CAPS

## Future Work

- [x] Screen rotation support
- [x] Objective-C version
- [ ] Infinite scroll option / Wrap items
- [ ] Carthage support
- [ ] More customization options

## Credits

[Niklas Fahl (fahlout)](http://bit.ly/fahlout) - iOS Developer

**Thank you for your contributions:**

[masarusanjp](https://github.com/masarusanjp)
* Type-safe options

[John C. Daub (hsoi)](https://github.com/hsoi)
* iOS 7.1 fixes
* Content size fixes on viewDidLayoutSubviews()

[Gurpartap Singh (Gurpartap)](https://github.com/gurpartap)
* CocoaPods fixes
* ScrollToTop fixes

[Chao Ruan (rcgary)](https://github.com/rcgary)
* Swift 1.2 Support

## Update Log

**1.2.7 Release (06/05/2015)**
* CocoaPods now has current version
* Objective-C version in Beta
* Demos updated

**1.2.6 Release (05/26/2015)**
* Options are now type-safe - Thanks to [masarusanjp](https://github.com/masarusanjp)

**1.2.5 Release (04/14/2015)**
* Support for Swift 1.2 - Thanks to [Chao Ruan (rcgary)](https://github.com/rcgary)
* Will be on cocoa pods soon!

**1.2.4 Release (03/24/2015)**
* Small improvements thanks to hsoi and kitasuke

**1.2.3 Release (02/09/2015)**
* iOS 7.1 errors resolved - hsoi
* Scroll to top now working for each page when tapping status bar - Gurpartap
* Now fully working with CocoaPods - Gurpartap

**1.2.2 Release (02/09/2015)**
* Now fully working with CocoaPods thanks to Gurpartap

**1.2.1 Release (02/02/2015)**
* Added delegate methods to know when page menu will move and did move to a certain page index
* Fixed bug where pages would disappear when tapping around on menu items
* Added a few more customization options (enableHorizontalBounce, hideTopMenuBar, menuItemSeparatorColor)
* Edited Demo 5 to show how to set up view controllers and page menu in order to be able to push from cells, etc.
* **Changed setup of PageMenu to eliminate some common issues (Please be aware that you will need to make a few changes in your project if you're already using PageMenu)**

**1.2.0 Release (01/26/2015)**
* Added ability to center menu items if they don't span over entire width of the PageMenu view (currently only supported for fixed menu item width)
* Added ability to use PageMenu in a similar way as segmented control
* Added function to move to any page index in PageMenu

**1.1.1 Release (01/16/2015)**
* Fixed bug that prevented user from tapping anything within a controller
* Menu now fully scrollable

**1.1.0 Release (01/15/2015)**
* Major performance improvements
* Auto-rotation bug fixed
* Customization option added for scroll animation duration on menu item tap

## License ##

Copyright (c) 2014 The Board of Trustees of The University of Alabama
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. Neither the name of the University nor the names of the contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.
