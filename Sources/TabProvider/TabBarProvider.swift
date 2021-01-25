//
//  Created by iWw on 2020/12/25.
//

import UIKit

struct TabBarProviderKeys {
    static var tabBarKey = "__Launcher.TabProvider.TabBarProvider.TabBarKey"
    static var tabBarTabProvidersKey = "__Launcher.TabProvider.TabBarProvider.TabBarTabProvidersKey"
    static var tabBarCurrentIndexkey = "__Launcher.TabProvider.TabBarProvider.TabBarCurrentIndexKey"
    static var tabBarInitialIdentifierKey = "__Launcher.TabProvider.TabBarProvider.TabBarInitialIdentifierKey"
}

public protocol TabBarProvider {
    
    /// tabbar's tab providers
    var tabProviders: [TabProvider] { get set }
    
    /// index of the tabbar's tab
    var tabBarCurrentIndex: Int { get set }
    
    /// tabbar selected index initial value
    var initialTabIdentifier: String? { get set }
    
    /// setTitleTextAttributes or other something
    func configure(tabBarItems: [UITabBarItem])
    
}

public extension TabBarProvider where Self: UITabBarController {
    
    var tabProviders: [TabProvider] {
        get {
            objc_getAssociatedObject(self, &TabBarProviderKeys.tabBarTabProvidersKey) as? [TabProvider] ?? []
        }
        set {
            objc_setAssociatedObject(self, &TabBarProviderKeys.tabBarTabProvidersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var tabBarCurrentIndex: Int {
        get {
            objc_getAssociatedObject(self, &TabBarProviderKeys.tabBarCurrentIndexkey) as? Int ?? -1
        }
        set {
            objc_setAssociatedObject(self, &TabBarProviderKeys.tabBarCurrentIndexkey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var initialTabIdentifier: String? {
        get {
            objc_getAssociatedObject(self, &TabBarProviderKeys.tabBarInitialIdentifierKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &TabBarProviderKeys.tabBarInitialIdentifierKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    func configure(tabBarItems: [UITabBarItem]) { }
}
