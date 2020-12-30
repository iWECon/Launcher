//
//  Created by iWw on 2020/12/30.
//

import UIKit
import RTNavigationController

/// Use with RootController if needed
/// when calling `prepareRootController(firstLaunch:)`
/// use `window.rootViewController = RootController/orSubClass.wrapRootNavigationController(initial:)`
public protocol RootNavigationProvider {
    
    static func wrapRootNavigationControler(initial: Bool) -> RTRootNavigationController
    func wrapRootNavigationControler() -> RTRootNavigationController
    
}

extension RootNavigationProvider where Self: RootController {
    
    static func wrapRootNavigationControler(initial: Bool) -> RTRootNavigationController {
        let vc = Self()
        vc.isInitial = initial
        return RTRootNavigationController(rootViewController: vc)
    }
    
    func wrapRootNavigationControler() -> RTRootNavigationController {
        RTRootNavigationController(rootViewController: self)
    }
}
