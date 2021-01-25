//
//  Created by iWw on 2020/12/22.
//

import UIKit

@objc public protocol ApplicationDelegateProvider: UIApplicationDelegate {
    
    /// call when will enter foreground
    /// maybe use GeTuiSDK.resetBadge() or other some third party to clear the badges number
    /// and those:
    /// UIApplication.shared.applicationIconBadgeNumber = 0
    /// UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    /// UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    func badgesClear()
    
}

public extension ApplicationDelegateProvider where Self: AppDelegateConfigurable {
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        delegates.forEach({ $0.applicationDidBecomeActive?(application) })
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        delegates.forEach({ $0.applicationWillResignActive?(application) })
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        delegates.forEach({ $0.applicationDidEnterBackground?(application) })
        application.ignoreSnapshotOnNextApplicationLaunch()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        delegates.forEach({ $0.applicationWillEnterForeground?(application) })
        badgesClear()
    }
    
    func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
        application.ignoreSnapshotOnNextApplicationLaunch()
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        delegates.forEach{ $0.application?(application, performActionFor: shortcutItem, completionHandler: completionHandler) }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        for delegate in delegates {
            if delegate.application?(app, open: url, options: options) == true {
                return true
            }
        }
        return false
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        delegates.forEach{ $0.applicationDidReceiveMemoryWarning?(application) }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        delegates.forEach{ $0.applicationWillTerminate?(application) }
    }
    
    func applicationSignificantTimeChange(_ application: UIApplication) {
        delegates.forEach{ $0.applicationSignificantTimeChange?(application) }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        delegates.forEach{ $0.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)}
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        delegates.forEach{ $0.application?(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler) }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        for delegate in delegates {
            if delegate.application?(application, continue: userActivity, restorationHandler: restorationHandler) == true {
                return true
            }
        }
        return false
    }
    
    func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        UserDefaults.resetStandardUserDefaults()
    }
}

