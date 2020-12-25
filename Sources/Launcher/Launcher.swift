//
//  Created by iWw on 2020/12/21.
//

import UIKit

public class Launcher: UIResponder {
    
    private override init() {
        super.init()
    }
    
    public static let shared = Launcher()
    
    public private(set) var window: UIWindow!
    public private(set) var delegates: [UIApplicationDelegate] = []
    
    private var appDelegateConfigurable: AppDelegateConfigurable!
    
    public func launch(_ appDelegate: UIResponder & UIApplicationDelegate, application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let prepare = appDelegate as? ApplicationPrepareConfigurable {
            prepare.applicationPrepare()
        }
        
        if let injects = appDelegate as? InjectsConfigurable {
            injects.methodSwizzleInjects()
        }
        
        if let tools = appDelegate as? ToolsConfigurable {
            tools.toolsConfigure()
        }
        
        // BOLD SIZE
        if UIAccessibility.isBoldTextEnabled {
            UILabel.appearance(whenContainedInInstancesOf: [UIButton.self]).lineBreakMode = .byClipping
        }
        NotificationCenter.default.addObserver(self, selector: #selector(boldTextDidChangeNotification(_:)), name: UIAccessibility.boldTextStatusDidChangeNotification, object: nil)
        
        guard let configurable = appDelegate as? AppDelegateConfigurable else {
            fatalError("Should be implement `AppDelegateConfigurable` protocol.")
        }
        self.appDelegateConfigurable = configurable
        self.delegates = configurable.delegates
        
        configurable.delegates.forEach({ let _ = $0.application?(application, didFinishLaunchingWithOptions: launchOptions) })
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        configurable.configure(window: self.window)
        
        configurable.prepareRootController(firstLaunch: true)
        
        return true
    }
    
    @objc private func boldTextDidChangeNotification(_ notify: Notification) {
        if UIAccessibility.isBoldTextEnabled {
            (UILabel.appearance(whenContainedInInstancesOf: [UIButton.self])).lineBreakMode = .byClipping
        } else {
            (UILabel.appearance(whenContainedInInstancesOf: [UIButton.self])).lineBreakMode = .byTruncatingTail
        }
    }
    
    /// prepare root controller
    /// - Parameter firstLaunch: Default is `false`
    public func prepareRootController(firstLaunch: Bool = false) {
        appDelegateConfigurable.prepareRootController(firstLaunch: firstLaunch)
    }
    
}
