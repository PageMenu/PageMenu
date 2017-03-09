//
//  PageMenuBar.swift
//  PageMenu
//
//  Created by Matthew York on 3/9/17.
//  Copyright © 2017 Center for Advanced Public Safety. All rights reserved.
//

import Foundation

open class PageMenuBar {
    internal var toolbar = UIToolbar(frame: CGRect.zero)
    public var items: [PageMenuItem]?
    public var selectedItem: PageMenuItem?
    
    public var barStyle: UIBarStyle {
        get {
            return self.toolbar.barStyle
        }
        set {
            self.toolbar.barStyle = newValue
        }
    }
    
    public var barTintColor: UIColor? {
        get {
            return self.toolbar.barTintColor
        }
        set {
            self.toolbar.barTintColor = newValue
        }
    }
    
    public var isTranslucent: Bool {
        get {
            return self.toolbar.isTranslucent
        }
        set {
            self.toolbar.isTranslucent = newValue
        }
    }
}

// MARK: - UIToolbar Bindings
extension PageMenuBar {

    open func setShadowImage(_ shadowImage: UIImage?, forToolbarPosition topOrBottom: UIBarPosition) {
        return self.toolbar.setShadowImage(shadowImage, forToolbarPosition: topOrBottom)
    }

    open func shadowImage(forToolbarPosition topOrBottom: UIBarPosition) -> UIImage? {
        return self.toolbar.shadowImage(forToolbarPosition: topOrBottom)
    }
}
