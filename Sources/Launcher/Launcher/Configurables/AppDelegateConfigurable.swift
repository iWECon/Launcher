//
//  Created by iWw on 2020/12/21.
//

import UIKit

fileprivate var AppDelegateConfigurableWindowKey = "AppDelegateConfigurable.WindowKey"

public protocol AppDelegateConfigurable {
    
    var delegates: [UIApplicationDelegate] { get }
    
    func configure(window: UIWindow)
    
    // 二选一
    /// 自动设置根控制器，业务功能简单的情况下可以用方法直接处理
    func autoSetRootController(firstLaunch isFirstLaunch: Bool) -> UIViewController?
    
    /// 业务逻辑复杂的可以走这个自定义，需要手动设置：window.rootViewController
    func prepareRootController(firstLaunch isFirstLaunch: Bool)
}

public extension AppDelegateConfigurable {
    
    var delegates: [UIApplicationDelegate] {
        []
    }
    
    func autoSetRootController(firstLaunch isFirstLaunch: Bool) -> UIViewController? { nil }
    
    func prepareRootController(firstLaunch isFirstLaunch: Bool) { }
}
