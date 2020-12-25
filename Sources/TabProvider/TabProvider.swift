//
//  Created by iWw on 2020/12/21.
//

import UIKit

public protocol TabProvider {
    
    var tabIdentifier: String { get }
    
    var tabTitle: String { get }
    var tabImageName: String { get }
    
    var tabBarItem: UITabBarItem { get }
    var controller: UIViewController { get }
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
    
}
