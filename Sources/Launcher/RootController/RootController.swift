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

open class RootController: UIViewController, UITabBarDelegate {
    
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
    
    public var isInitial = false
    
    /// return the current tab's root controller
    public private(set) var currentController: UIViewController!
    public private(set) lazy var contentView = UIView()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    public convenience init(initial: Bool = false) {
        self.init(nibName: nil, bundle: nil)
        self.isInitial = initial
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
            return
        }
        view.addSubview(contentView)
        
        // constraint contentView
        constraintsControllerContainerView()
        
        // install tab providers
        // find the intialTabIdentifier's controller
        let initialProvider = tabBarProvider.tabProviders.enumerated().filter({ $0.element.tabIdentifier == tabBarProvider.initialTabIdentifier }).first
        currentController = initialProvider?.element.controller ?? tabBarProvider.tabProviders.first!.controller
        
        tabBarProvider.tabBar.delegate = self
        tabBarProvider.tabBar.setItems(tabBarProvider.tabProviders.compactMap({ $0.tabBarItem }), animated: false)
        for (idx, item) in (tabBarProvider.tabBar.items ?? []).enumerated() {
            item.tag = idx
        }
        view.addSubview(tabBarProvider.tabBar)
        constraintsTabBar(tabBar: tabBarProvider.tabBar)
        
        tabBarSelectItem(at: initialProvider?.offset ?? 0)
    }
    
    /// call when is initial run
    open func initialLoad() {
        
    }
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
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
    
    open func tabBarItemDidChange(to index: Int) {
        
    }
}

private extension RootController {
    
    private func constraintsControllerContainerView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -(49 + Screen.safeArea.bottom))
        
        view.addConstraints([topConstraint, leftConstraint, rightConstraint, bottomConstraint])
    }
    
    private func constraintsTabBar(tabBar: UITabBar) {
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        let leftConstraint = NSLayoutConstraint(item: tabBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: tabBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: tabBar, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: tabBar, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([leftConstraint, rightConstraint, bottomConstraint, topConstraint])
    }
    
}

private extension RootController {
    
    func tabBarSelectItem(at index: Int) {
        tabBarSelectItem(at: index, skipRefresh: false)
    }
    
    func tabBarSelectItem(at index: Int, skipRefresh: Bool, segment: Any? = nil) {
        guard let tabBarProvider = self as? TabBarProvider else { return }
        var currentIndex = tabBarProvider.tabBarCurrentIndex
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
        
        func replaceCurrentControllerViewConstraint(_ controllerView: UIView) {
            guard currentController.view != self.view else { return }
            
            controllerView.translatesAutoresizingMaskIntoConstraints = false
            
            // shit
            contentView.addConstraints([
                .init(item: contentView, attribute: .top, relatedBy: .equal, toItem: controllerView, attribute: .top, multiplier: 1, constant: 0),
                .init(item: controllerView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0),
                .init(item: contentView, attribute: .right, relatedBy: .equal, toItem: controllerView, attribute: .right, multiplier: 1, constant: 0),
                .init(item: controllerView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0),
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
        var controller = tabProvider.controller
        if let containerProvider = tabProvider as? ContainerNavigationProvider {
            controller = containerProvider.wrapContainerNavigationController()
        }
        currentController = controller
        addChild(currentController)
        currentController.willMove(toParent: self)
        contentView.addSubview(currentController.view)
        replaceCurrentControllerViewConstraint(currentController.view)
        currentController.didMove(toParent: self)
        setNeedsStatusBarAppearanceUpdate()
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
