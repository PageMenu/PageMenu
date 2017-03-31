//
//  UIViewController+PageMenu.swift
//  PageMenu
//
//  Created by Matthew York on 3/9/17.
//  Copyright © 2017 Center for Advanced Public Safety. All rights reserved.
//

import Foundation

extension UIViewController {
    private struct InternalPageMenuVariables {
        static var pageMenuItem: PageMenuItem?
        static var pageMenuController: PageMenuController?
    }
    
    public var pageMenuItem: PageMenuItem? {
        get{
            return objc_getAssociatedObject(self, &InternalPageMenuVariables.pageMenuItem) as? PageMenuItem
        }
        set {
            objc_setAssociatedObject(self, &InternalPageMenuVariables.pageMenuItem, newValue as PageMenuItem?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var pageMenuController: PageMenuController? {
        get{
            return objc_getAssociatedObject(self, &InternalPageMenuVariables.pageMenuController) as? PageMenuController
        }
        set {
            objc_setAssociatedObject(self, &InternalPageMenuVariables.pageMenuController, newValue as PageMenuController?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
