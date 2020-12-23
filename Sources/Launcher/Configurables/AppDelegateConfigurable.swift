//
//  Created by iWw on 2020/12/21.
//

import UIKit

fileprivate var AppDelegateConfigurableWindowKey = "AppDelegateConfigurable.WindowKey"

public protocol AppDelegateConfigurable {
    
    var window: UIWindow { get set }
    
    var delegates: [UIApplicationDelegate] { get }
    
    func configure(window: UIWindow)
    
    func prepareRootController(firstLaunch isFirstLaunch: Bool)
}

public extension AppDelegateConfigurable {
    
    var delegates: [UIApplicationDelegate] {
        []
    }
    
    var window: UIWindow {
        get {
            guard let window = objc_getAssociatedObject(self, &AppDelegateConfigurableWindowKey) as? UIWindow else {
                let window = UIWindow(frame: UIScreen.main.bounds)
                objc_setAssociatedObject(self, &AppDelegateConfigurableWindowKey, window, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return window
            }
            return window
        }
        set {
            objc_setAssociatedObject(self, &AppDelegateConfigurableWindowKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func configure(window: UIWindow) { }
}
