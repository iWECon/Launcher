//
//  Created by iWw on 2020/12/30.
//

import UIKit
import RTNavigationController
#if SWIFT_PACKAGE
import TabProvider
#endif

public protocol ContainerNavigationProvider {
    
    func wrapContainerNavigationController() -> RTContainerNavigationController
    
}


public extension ContainerNavigationProvider where Self: TabProvider {
    
    func wrapContainerNavigationController() -> RTContainerNavigationController {
        RTContainerNavigationController(rootViewController: self.controller)
    }
    
}
