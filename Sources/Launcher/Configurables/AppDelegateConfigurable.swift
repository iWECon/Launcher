//
//  Created by iWw on 2020/12/21.
//

import UIKit

fileprivate var AppDelegateConfigurableWindowKey = "AppDelegateConfigurable.WindowKey"

public protocol AppDelegateConfigurable {
    
    var delegates: [UIApplicationDelegate] { get }
    
    func configure(window: UIWindow)
    
    func prepareRootController(firstLaunch isFirstLaunch: Bool)
    
}

public extension AppDelegateConfigurable {
    
    var delegates: [UIApplicationDelegate] {
        []
    }
    
}
