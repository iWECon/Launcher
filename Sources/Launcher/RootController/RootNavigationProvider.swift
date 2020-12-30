//
//  Created by iWw on 2020/12/30.
//

import UIKit
import RTNavigationController

/// Use with RootController if needed
/// when calling `prepareRootController(firstLaunch:)`
/// use `window.rootViewController = RootController/orSubClass.wrapRootNavigationController(initial:)`
public protocol RootNavigationProvider {
    
    func wrapRootNavigationControler() -> RTRootNavigationController
    
}

public extension RootNavigationProvider where Self: RootController {
    
    func wrapRootNavigationControler() -> RTRootNavigationController {
        RTRootNavigationController(rootViewController: self)
    }
}
