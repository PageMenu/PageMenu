PageMenu
========

A paging menu controller built from other view controllers allowing the user to switch between controller views with an easy tap or swipe gesture

<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuScreen1.png" alt="PageMenuScreen1">
<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuScreen2.png" alt="PageMenuScreen2">
<img src="https://raw.githubusercontent.com/uacaps/ResourceRepo/master/PageMenu/PageMenuScreen3.png" alt="PageMenuScreen3">


## Installation

**Cocoa Pods**

Coming in the future.

**Manual Installation**

The classes required for CAPSPageMenu are located in the CAPSPageMenu folder in the root of this repository as listed below:

* <code>CAPSPageMenu.swift<code>
* <code>CAPSPageMenu.xib<code>

## How to use CAPSPageMenu

First you will have to create a view controller that is supposed to serve as the base of the page menu. This can be a view controller with its xib file as a separate file as well as having its xib file in storyboard. Following this you will have to go through a few simple steps outlined below in order to get everything up and running.

1) Add the files listed in the installation section to your project

2) Add a property for CAPSPageMenu in your base view controller

```objective-c
var pageMenu : CAPSPageMenu?
```

3) Add the following code in the viewDidAppear function in your view controller

```objective-c
// Array to keep track of controllers in page menu
var controllerArray : [UIViewController] = []

// Create variables for all view controllers you want to put in the page menu, initialize them, and add each to the controller array. 
// Make sure the title property of all view controllers is set
// Example:
var controller : TestViewController = TestViewController(nibName: "TestViewController", bundle: nil)
controller.title = "SAMPLE TITLE"
controllerArray.append(controller)
```

## Future Work

- [ ] No xib file required
- [ ] Objective-C version
- [ ] Landscape support

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
