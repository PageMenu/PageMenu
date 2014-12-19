PageMenu
========

A paging menu controller built from other view controllers allowing the user to switch between controller views with an easy tap or swipe gesture

<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuDemo.gif" alt="PageMenuDemo">
<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuScreen1.png" alt="PageMenuScreen1">
<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuScreen2.png" alt="PageMenuScreen2">

## Installation

**Cocoa Pods**

Coming once Swift support gets added to Cocoa Pods.

**Manual Installation**

The only class required for CAPSPageMenu is located in the CAPSPageMenu folder in the root of this repository as listed below:

* <code>CAPSPageMenu.swift<code>

## How to use CAPSPageMenu

First you will have to create a view controller that is supposed to serve as the base of the page menu. This can be a view controller with its xib file as a separate file as well as having its xib file in storyboard. Following this you will have to go through a few simple steps outlined below in order to get everything up and running.

1)  Add the files listed in the installation section to your project

2)  Add a variable or property for CAPSPageMenu in your base view controller

```swift
var pageMenu : CAPSPageMenu?
```

3)  Add the following code in the viewDidAppear function in your view controller

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

// Initialize page menu with the controllers
pageMenu = CAPSPageMenu(viewControllers: controllerArray)

// Set frame for page menu
// Example:
pageMenu!.view.frame = CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height)

// Customize page menu to your liking (optional) or use default settings
// Example:
pageMenu!.scrollMenuBackgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
pageMenu!.viewBackgroundColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
pageMenu!.selectionIndicatorColor = UIColor.orangeColor()
pageMenu!.bottomMenuHairlineColor = UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0)
pageMenu!.menuItemFont = UIFont(name: "HelveticaNeue", size: 13.0)
pageMenu!.menuHeight = 40.0

// Lastly add page menu as subview of base view controller view
// or use pageMenu controller in you view hierachy as desired
self.view.addSubview(pageMenu!.view)
```

4)  You should now be ready to use CAPSPageMenu!! 🎉

## Customization

There are many ways you are able to customize page menu for your needs and there will be more customizations coming in the future to make sure page menu conforms to your app design. These will all be properties in CAPSPageMenu that can be changed from your base view controller. (Property names given with each item below)

1)  Colors

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


  * Bottom menu hairline color

        bottomMenuHairlineColor (UIColor)



2)  Dimensions

  * Scroll menu height

        menuHeight (CGFloat)


  * Scroll menu margin (leading space before first menu item and after last menu item as well as in between items)

        menuMargin (CGFloat)


  * Scroll menu item width

        menuItemWidth (CGFloat)


  * Selection indicator height

        selectionIndicatorHeight (CGFloat)



3)  Others
  * Menu item title label font

        menuItemFont (UIFont)


  * Bottom menu hairline

        addBottomMenuHairline (Bool)



## Future Work

- [ ] More demos
- [ ] Screen rotation support
- [ ] Objective-C version
- [ ] More customization options

## Credits ##

* <a href="https://github.com/fahlout">Niklas Fahl</a> - iOS Developer

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
