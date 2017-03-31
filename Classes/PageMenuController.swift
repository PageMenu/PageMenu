//
//  PageMenuController.swift
//  PageMenu
//
//  Created by Grayson Webster on 3/31/2017.
//  Copyright © 2017 Center for Advanced Public Safety. All rights reserved.
//

import UIKit

open class PageMenuController : UIViewController {
    
    // MARK: - Properties
    var reuseIdentifier = "PageCell"
    var pages: [UIViewController] = []
    var menuItems: [PageMenuItem] = []
    
    public var pageMenuBar: PageMenuBar!
    
    // MARK: - Setup
    override open func viewDidLoad() {
        super.viewDidLoad()
        pageMenuBar = PageMenuBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44.0))
        setDefaultCollectionView()
        view.addSubview(pageMenuBar!)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Configure Collection View
    func setDefaultCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = view.bounds.size
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.bounces = false
    }
    
    // MARK: - Add/Remove Pages
    public func addPage(_ controller: UIViewController) {
        pages.append(controller)
        menuItems.append(itemFromPage(controller: controller, name: nil))
    }
    
    public func addPage(_ controller: UIViewController, at: Int) {
        pages.insert(controller, at: at)
        menuItems.insert(itemFromPage(controller: controller, name: nil), at: at)
    }
    
    public func addPage(_ controller: UIViewController, name: String) {
        pages.append(controller)
        menuItems.append(itemFromPage(controller: controller, name: nil))
    }
    
    public func addPage(_ controller: UIViewController, name: String, at: Int) {
        pages.insert(controller, at: at)
        menuItems.insert(itemFromPage(controller: controller, name: name), at: at)
    }
    
    public func removeLastPage() {
        pages.remove(at: pages.count - 1)
        menuItems.remove(at: menuItems.count - 1)
    }
    
    public func removePage(at: Int) {
        pages.remove(at: at)
        menuItems.remove(at: at)
    }
    
    // MARK: - Create Menu Items
    func itemFromPage(controller: UIViewController, name: String?) -> PageMenuItem {
        let item = PageMenuItem()
        if (name != nil) {
            item.titleLabel?.text = name
        } else {
            item.titleLabel?.text = controller.title
        }
        return item
    }
}

// MARK: - Private
private extension PageMenuController {
    func pageForIndexPath(_ indexPath: IndexPath) -> UIView {
        return pages[(indexPath as NSIndexPath).section].view
    }
}


// MARK: - UICollectionViewDataSource
extension PageMenuController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return pages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as UICollectionViewCell
        cell.contentView.addSubview(pageForIndexPath(indexPath))
        return cell
    }
    
}
