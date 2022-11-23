//
//  Created by iWw on 2020/12/25.
//

import UIKit
import Pager
import Segmenter
import SegmentedController
#if SWIFT_PACKAGE
import TabProvider
#endif

open class RootController: UITabBarController {
    
    deinit {
        (self as? TabBarProvider)?.tabProviders.forEach({ $0.cleanup() })
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        currentController
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        childForStatusBarStyle?.preferredStatusBarStyle ?? .default
    }
    
    public private(set) var currentController: UIViewController!
    @IBInspectable public var isInitial = false
    
    required public init(initial: Bool) {
        self.isInitial = initial
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// 首次加载 RootController 已走完 `viewDidLoad` 且 `isInitial = true` 时触发
    /// call it when `viewDidLoad` trigger after and `isInitial = true`
    /// override in subclass
    open func initialDidLoad() { }
    
    /// 每次加载 RootController, 触发 `viewDidLoad` 时都会触发
    /// call it when `viewDidLoad` trigger after
    /// override in subclass
    open func thenDidLoad() { }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        defer {
            if isInitial {
                isInitial = false
                DispatchQueue.main.async { self.initialDidLoad() }
            }
            DispatchQueue.main.async { self.thenDidLoad() }
        }
        
        navigationController?.isNavigationBarHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        setupTabBar()
        initialTabBar()
    }
    
    open func setupTabBar() {
        guard let tabBarProvider = self as? TabBarProvider,
              !tabBarProvider.tabProviders.isEmpty
        else {
            tabBar.isHidden = true
            return
        }
        tabBar.isTranslucent = false
    }
    
    open func initialTabBar() {
        // setup tab bar
        guard let tabBarProvider = self as? TabBarProvider,
              !tabBarProvider.tabProviders.isEmpty
        else {
            return
        }
        installTabProviders(tabBarProvider: tabBarProvider)
        setupInitialTab(tabBarProvider: tabBarProvider)
    }
    
    /// If change provider.tabProviders,
    /// call `reloadTabBar` to refresh.
    open func reloadTabBar() {
        // setup tab bar
        guard let tabBarProvider = self as? TabBarProvider,
              !tabBarProvider.tabProviders.isEmpty
        else {
            return
        }
        installTabProviders(tabBarProvider: tabBarProvider)
    }
    
    /// install tab providers
    open func installTabProviders(tabBarProvider: TabBarProvider) {
        let controllers = tabBarProvider.tabProviders.map({ $0.controller })
        for (index, controller) in controllers.enumerated() {
            let tabItem = tabBarProvider.tabProviders[index].tabBarItem
            tabItem.tag = index
            controller.tabBarItem = tabItem
        }
        
        setViewControllers(controllers, animated: false)
        (self as? TabBarProvider)?.configure(tabBarItems: controllers.compactMap({ $0.tabBarItem }))
    }
    
    /// find the intialTabIdentifier's controller
    open func setupInitialTab(tabBarProvider: TabBarProvider) {
        let initialProvider = tabBarProvider.tabProviders.enumerated().filter({ $0.element.tabIdentifier == tabBarProvider.initialTabIdentifier }).first
        self.selectedIndex = initialProvider?.offset ?? 0
        self.currentController = initialProvider?.element.controller ?? tabBarProvider.tabProviders.first!.controller
        
        tabBarSelectItem(at: initialProvider?.offset ?? 0)
    }
    
    /// Change the tabBar selected tab.
    /// - Parameters:
    ///   - index: Tab index.
    ///   - segmentIndex: Segmenter index, if segmenter exists.
    open func selectItem(item index: Int, segment segmentIndex: Int = -1) {
        let tabIndex = max(0, min(index, (tabBar.items ?? []).count))
        self.selectedIndex = tabIndex
        self.currentController = (viewControllers ?? [])[tabIndex]
        
        guard segmentIndex >= 0,
              let segmentedable = self.currentController as? Segmentedable,
              segmentIndex < segmentedable.segmenter.segments.count
        else {
            return
        }
        
        self.segmentedDidChange(segmentIndex)
    }
    
    public override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        animateTabItemSelection(at: item.tag)
        tabBarSelectItem(at: item.tag, skipRefresh: false)
    }
    
    open func animateTabItemSelection(at index: Int) {
        if index + 1 >= tabBar.subviews.count {
            return
        }
        let iconView = tabBar.subviews[index + 1]
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            iconView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            
            UIView.animate(withDuration: 0.35, delay: 0.12, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                iconView.transform = .identity
                
            }, completion: nil)
        }, completion: nil)
    }
    
    /// override in subclass
    open func tabBarItemDidChange(to index: Int) { }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        navigationController?.isNavigationBarHidden = true
    }
    
}

extension RootController {

    open func tabBarSelectItem(at index: Int) {
        tabBarSelectItem(at: index, skipRefresh: false)
    }
    
    open func tabBarSelectItem(at index: Int, skipRefresh: Bool, segment: Any? = nil) {
        guard var tabBarProvider = self as? TabBarProvider else { return }
        let currentIndex = tabBarProvider.tabBarCurrentIndex
        let tabProviders = tabBarProvider.tabProviders

        guard index != currentIndex else {

            guard !skipRefresh,
                  let refreshable = currentController as? Refreshable
            else {
                return
            }

            refreshable.beginRefreshing()
            segmentedDidChange(segment)
            return
        }
        
        tabBarProvider.tabBarCurrentIndex = index
        
        let tabProvider = tabProviders[index]
        // bugfix: preferred status bar style
        self.currentController = tabProvider.controller
        self.selectedIndex = index
        
        tabBarItemDidChange(to: index)
        segmentedDidChange(segment)
    }
    
    open func segmentedControlDidChange(_ segmentedIndex: Int) {
        guard segmentedIndex >= 0,
              let pagable = currentController as? SegmentedControllerable,
              segmentedIndex < pagable.pages.count
        else {
            return
        }
        
        pagable.segmenter.currentIndex = segmentedIndex
        pagable.pager.currentIndex = segmentedIndex
    }

    open func segmentedDidChange(_ segment: Any?) {
        guard let segment = segment else {
            return
        }
        var index: Int = 0
        if let segmentInt = segment as? Int {
            index = segmentInt
        } else if let segmentString = segment as? String,
                  let segmentInt = Int(segmentString) {
            index = segmentInt
        } else {
            return
        }
        segmentedControlDidChange(index)
    }
}
