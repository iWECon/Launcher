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
    }()
}

open class RootController: UIViewController {
    
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
    
    public var controllerContainerView = UIView()
    
    public var isInitial = false
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        _commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        _commonInit()
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    private func _commonInit() {
        
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
            fatalError("implement at least one tabProvider")
        }
        currentController = tabProviders.first!.controller
        setNeedsStatusBarAppearanceUpdate()
        
        
        let topConstraint = NSLayoutConstraint(item: controllerContainerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: controllerContainerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: controllerContainerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: controllerContainerView, attribute: .bottomMargin, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 49 + Screen.safeArea.bottom)
        controllerContainerView.addConstraints([topConstraint, leftConstraint, rightConstraint, bottomConstraint])
        
        controllerContainerView.backgroundColor = .yellow
        
        view.addSubview(controllerContainerView)
    }
    
    /// call when is initial run
    open func initialLoad() {
        
    }
}
