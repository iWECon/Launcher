//
//  Created by iWw on 2020/12/25.
//

import UIKit
import TabProvider
import Launcher

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

open class RootController: UIViewController, UITabBarDelegate {
    
    open override var childForStatusBarStyle: UIViewController? {
        currentController
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let current = currentController {
            return current.preferredStatusBarStyle
        }
        return .default
    }
    
    /// return the current tab's root controller
    public private(set) var currentController: UIViewController!
    
    
    /// tabbar's tab providers
    open var tabProviders: [TabProvider] = []
    /// tabbar selected index initial value
    open var initialTabIndex = 0
    
    public var isInitial = false
    public var controllerContainerView = UIView()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
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
        
        // install tab providers
        if tabProviders.count <= 0  {
            // fatalError("implement at least one tabProvider")
            currentController = self
        } else {
            currentController = tabProviders.first!.controller
        }
        
        setNeedsStatusBarAppearanceUpdate()
        
        controllerContainerView.backgroundColor = .yellow
        
        view.addSubview(controllerContainerView)
        
        // constraint controllerContainerView
        controllerContainerView.translatesAutoresizingMaskIntoConstraints = false
        constraintsControllerContainerView()
        
        // setup tab bar
        guard let tabBarProvider = self as? TabBarProvider else {
            return
        }
        tabBarProvider.tabBar.delegate = self
        tabBarProvider.tabBar.setItems(tabProviders.compactMap({ $0.tabBarItem }), animated: true)
        for (idx, item) in (tabBarProvider.tabBar.items ?? []).enumerated() {
            item.tag = idx
        }
        view.addSubview(tabBarProvider.tabBar)
        
        tabBarProvider.tabBar.translatesAutoresizingMaskIntoConstraints = false
        constraintsTabBar(tabBar: tabBarProvider.tabBar)
        
        tabBarSelectItem(at: 0)
    }
    
    open func constraintsControllerContainerView() {
        let topConstraint = NSLayoutConstraint(item: controllerContainerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: controllerContainerView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: controllerContainerView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: controllerContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -(49 + Screen.safeArea.bottom))
        view.addConstraints([topConstraint, leftConstraint, rightConstraint, bottomConstraint])
    }
    
    open func constraintsTabBar(tabBar: UITabBar) {
        let leftConstraint = NSLayoutConstraint(item: tabBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: tabBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: tabBar, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: tabBar, attribute: .top, relatedBy: .equal, toItem: controllerContainerView, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([leftConstraint, rightConstraint, bottomConstraint, topConstraint])
        //controllerContainerView.addConstraint(topConstraint)
    }
    
    /// call when is initial run
    open func initialLoad() {
        
    }
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        animateTabItemSelection(at: item.tag)
        tabBarSelectItem(at: item.tag, skipRefresh: false)
    }
}


private extension RootController {
    
    func animateTabItemSelection(at index: Int) {
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
    
    func tabBarSelectItem(at index: Int) {
        tabBarSelectItem(at: index, skipRefresh: false)
    }
    
    func tabBarSelectItem(at index: Int, skipRefresh: Bool, segment: Any? = nil) {
        guard let tabBarProvider = self as? TabBarProvider else { return }
        var currentIndex = tabBarProvider.currentIndex
        let tabBar = tabBarProvider.tabBar
        
        guard index != currentIndex else {
            
//            if !skipRefresh, let current = currentController as? Refreshable {
//                current.beginRefreshing()
//                currentTabBar(change: segment)
//            }
            
            return
        }
        
        func replaceCurrentControllerViewConstraint(_ controllerView: UIView) {
            guard currentController.view != self.view else { return }
            
            controllerView.translatesAutoresizingMaskIntoConstraints = false
            
            // shit
            controllerContainerView.addConstraints([
                .init(item: controllerContainerView, attribute: .top, relatedBy: .equal, toItem: controllerView, attribute: .top, multiplier: 1, constant: 0),
                .init(item: controllerView, attribute: .left, relatedBy: .equal, toItem: controllerContainerView, attribute: .left, multiplier: 1, constant: 0),
                .init(item: controllerContainerView, attribute: .right, relatedBy: .equal, toItem: controllerView, attribute: .right, multiplier: 1, constant: 0),
                .init(item: controllerView, attribute: .bottom, relatedBy: .equal, toItem: controllerContainerView, attribute: .bottom, multiplier: 1, constant: 0),
            ])
        }
        
        currentIndex = index
        tabBar.selectedItem = tabBar.items![index]
        if currentController != nil {
            currentController.willMove(toParent: nil)
            currentController.beginAppearanceTransition(false, animated: false)
            currentController.view.removeFromSuperview()
            currentController.endAppearanceTransition()
            currentController.removeFromParent()
            currentController.didMove(toParent: nil)
        }
        let tabProvider = tabProviders[currentIndex]
        currentController = tabProvider.controller
        addChild(currentController)
        currentController.willMove(toParent: self)
        controllerContainerView.addSubview(currentController.view)
        replaceCurrentControllerViewConstraint(currentController.view)
        currentController.didMove(toParent: self)
        setNeedsStatusBarAppearanceUpdate()
        
        currentTabBar(change: segment)
    }
    
    /// use Index: Int, or Identifier: String
    func currentTabBar(change segment: Any?) {
        guard let segment = segment else {
            return
        }
        var index: Int
        if let segmentInt = segment as? Int {
            index = segmentInt
        } else if let segmentIdentifier = segment as? String {
            // index = segmentIdentifier
            index = -1
        } else {
            return
        }
//        if index >= 0, let pagable = currentController as? Pagable, index < pagable.pager.rootControllers.count {
//            let pager = pagable.pager
//            pager.segmenter?.currentIndex = index
//            pager.currentIndex = index
//        }
    }
    
}
