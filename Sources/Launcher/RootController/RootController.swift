//
//  Created by iWw on 2020/12/25.
//

import UIKit
import TabProvider
import Pager
import SegmentedController

private struct Screen {
    static var safeArea: UIEdgeInsets = {
        if #available(iOS 11.0, *) {
            let h = UIApplication.shared.statusBarFrame.height
            if h == 20 {
                return .zero
            }
            return Launcher.shared.window.safeAreaInsets
        }
        return .zero
    }()
}

open class RootController: UITabBarController {
    
    deinit {
        (self as? TabBarProvider)?.tabProviders.forEach({ $0.cleanup() })
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        currentController
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let current = currentController {
            return current.preferredStatusBarStyle
        }
        return .default
    }
    
    public private(set) var currentController: UIViewController!
    public var isInitial = false
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    required public init(initial: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.isInitial = initial
        commonInit()
    }
    
    /// do not make time-consuming tasks
    /// you can listen some notify
    /// call before viewDidLoad
    open func commonInit() {
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if isInitial {
            // do something for initial
            initialLoad()
        }
        
        navigationController?.isNavigationBarHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        // setup tab bar
        guard let tabBarProvider = self as? TabBarProvider,
              tabBarProvider.tabProviders.count > 0
        else {
            tabBar.isHidden = true
            return
        }
        
        tabBar.isTranslucent = false
        
        // install tab providers
        let controllers = tabBarProvider.tabProviders.map({ $0.controller })
        for (index, controller) in controllers.enumerated() {
            let tabItem = tabBarProvider.tabProviders[index].tabBarItem
            controller.tabBarItem = tabItem
            controller.tabBarItem.tag = index
        }
        setViewControllers(controllers, animated: false)
        
        // find the intialTabIdentifier's controller
        let initialProvider = tabBarProvider.tabProviders.enumerated().filter({ $0.element.tabIdentifier == tabBarProvider.initialTabIdentifier }).first
        currentController = initialProvider?.element.controller ?? tabBarProvider.tabProviders.first!.controller
        
        tabBarSelectItem(at: initialProvider?.offset ?? 0)
    }
    
    /// call when is initial run
    /// override in subclass
    open func initialLoad() {
        
    }
    
    public override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        animateTabItemSelection(at: item.tag)
        tabBarSelectItem(at: item.tag, skipRefresh: false)
    }
    
    open func animateTabItemSelection(at index: Int) {
        guard let tabBar = (self as? TabBarProvider)?.tabBar else { return }
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
}

private extension RootController {

    func tabBarSelectItem(at index: Int) {
        tabBarSelectItem(at: index, skipRefresh: false)
    }

    func tabBarSelectItem(at index: Int, skipRefresh: Bool, segment: Any? = nil) {
        guard var tabBarProvider = self as? TabBarProvider else { return }
        let currentIndex = tabBarProvider.tabBarCurrentIndex
        let tabBar = tabBarProvider.tabBar
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
        tabBar.selectedItem = tabBar.items![index]
        
        let tabProvider = tabProviders[index]
        self.currentController = tabProvider.controller
        
        tabBarItemDidChange(to: index)
        segmentedDidChange(segment)
    }
    
    func segmentedControlDidChange(_ segmentedIndex: Int) {
        guard segmentedIndex >= 0,
              let pagable = currentController as? SegmentedControllerable,
              segmentedIndex < pagable.pages.count
        else {
            return
        }

        pagable.segmenter.currentIndex = segmentedIndex
        pagable.pager.currentIndex = segmentedIndex
    }

    func segmentedDidChange(_ segment: Any?) {
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
