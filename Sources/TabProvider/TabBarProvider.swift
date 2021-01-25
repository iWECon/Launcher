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
    
    var tabBar: UITabBar { get set }
    
    /// tabbar's tab providers
    var tabProviders: [TabProvider] { get set }
    
    /// index of the tabbar's tab
    var tabBarCurrentIndex: Int { get set }
    
    /// tabbar selected index initial value
    var initialTabIdentifier: String? { get set }
    
    /// setTitleTextAttributes or other something
    func configure(tabBarItems: [UITabBarItem])
    
}

public extension TabBarProvider {
    
    var tabProviders: [TabProvider] { [] }
    var tabBarCurrentIndex: Int { -1 }
    var initialTabIdentifier: String? { nil }
    
}

public extension TabBarProvider where Self: UIViewController {
    
    var tabBar: UITabBar {
        get {
            guard let tabBar = objc_getAssociatedObject(self, &TabBarProviderKeys.tabBarKey) as? UITabBar else {
                let tabBar = UITabBar()
                tabBar.isTranslucent = false
                tabBar.shadowImage = UIImage()
                tabBar.backgroundImage = UIImage()
                tabBar.clipsToBounds = false
                
                objc_setAssociatedObject(self, &TabBarProviderKeys.tabBarKey, tabBar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                return tabBar
            }
            return tabBar
        }
        
        set {
            objc_setAssociatedObject(self, &TabBarProviderKeys.tabBarKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func configure(tabBarItems: [UITabBarItem]) { }
}
