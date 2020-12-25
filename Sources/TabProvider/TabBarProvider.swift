//
//  Created by iWw on 2020/12/25.
//

import UIKit

private var __TabBarKey = "__Launcher.TabProvider.TabBarProvider.TabBarKey"

public protocol TabBarProvider {
    
    var tabBarTintColor: UIColor? { get set }
    
    var tabBar: UITabBar { get set }
    
    /// index of the tabbar's tab
    var currentIndex: Int { get set }
    
    /// setTitleTextAttributes or other something
    func configure(tabBarItems: [UITabBarItem])
    
}

public extension TabBarProvider {
    
    var tabBar: UITabBar {
        get {
            guard let tabBar = objc_getAssociatedObject(self, &__TabBarKey) as? UITabBar else {
                let tabBar = UITabBar()
                tabBar.isTranslucent = false
                tabBar.tintColor = tabBarTintColor
                tabBar.shadowImage = UIImage()
                tabBar.backgroundImage = UIImage()
                tabBar.clipsToBounds = false
                tabBar.layer.shadowColor = UIColor(red: 189 / 255.0, green: 189 / 255.0, blue: 189 / 255.0, alpha: 0.5).cgColor
                tabBar.layer.shadowOpacity = 1.0
                
                objc_setAssociatedObject(self, &__TabBarKey, tabBar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                return tabBar
            }
            return tabBar
        }
        
        set {
            objc_setAssociatedObject(self, &__TabBarKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
