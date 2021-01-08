//
//  Created by iWw on 2020/12/21.
//

import UIKit


struct TabProviderKeys {
    static var tabInitialSegmentedIndexKey = "__Launcher.TabProvider.tabInitialSegmentedIndexKey"
}

public protocol TabProvider {
    
    var tabIdentifier: String { get }
    
    var tabTitle: String { get }
    /// the selected image name use: tabImageName + "_sel"
    var tabImageName: String { get }
    
    var tabBarItem: UITabBarItem { get }
    var controller: UIViewController { get }
    
    /// clear controller if needed
    func cleanup()
    /// badges update
    func set(badge: Int)
}


public extension TabProvider {
    
    var tabBarItem: UITabBarItem {
        let image = UIImage(named: tabImageName)?.withRenderingMode(.alwaysOriginal)
        let selectedImage = UIImage(named: tabImageName + "_sel")?.withRenderingMode(.alwaysOriginal)
        let item = UITabBarItem(title: tabTitle, image: image, selectedImage: selectedImage)
        if UIDevice.current.userInterfaceIdiom == .phone {
            item.titlePositionAdjustment = UIOffset.init(horizontal: 0, vertical: -2)
        }
        return item
    }
    
    func cleanup() { }
    func set(badge: Int) { }
}
