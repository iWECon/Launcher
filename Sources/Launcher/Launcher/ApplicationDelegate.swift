//
//  Created by iWw on 2020/12/22.
//

import UIKit

open class ApplicationDelegate: UIResponder, UIApplicationDelegate, AppDelegateConfigurable {
    
    open var window: UIWindow? = nil
    
    open func configure(window: UIWindow) {
        self.window = window
    }
    
    /// call when will enter foreground
    /// maybe use GeTuiSDK.resetBadge() or other some third party to clear the badges number
    /// and those:
    /// UIApplication.shared.applicationIconBadgeNumber = 0
    /// UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    /// UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    open func badgesClear() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    // MARK:- UIApplicationDelegate
    open func applicationDidBecomeActive(_ application: UIApplication) {
        delegates.forEach({ $0.applicationDidBecomeActive?(application) })
    }
    
    open func applicationWillResignActive(_ application: UIApplication) {
        delegates.forEach({ $0.applicationWillResignActive?(application) })
    }
    
    open func applicationDidEnterBackground(_ application: UIApplication) {
        delegates.forEach({ $0.applicationDidEnterBackground?(application) })
        application.ignoreSnapshotOnNextApplicationLaunch()
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
        delegates.forEach({ $0.applicationWillEnterForeground?(application) })
        badgesClear()
    }
    
    open func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
        application.ignoreSnapshotOnNextApplicationLaunch()
    }
    
    open func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        delegates.forEach{ $0.application?(application, performActionFor: shortcutItem, completionHandler: completionHandler) }
    }
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        for delegate in delegates {
            if delegate.application?(app, open: url, options: options) == true {
                return true
            }
        }
        return false
    }
    
    open func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        delegates.forEach{ $0.applicationDidReceiveMemoryWarning?(application) }
    }
    
    open func applicationWillTerminate(_ application: UIApplication) {
        delegates.forEach{ $0.applicationWillTerminate?(application) }
    }
    
    open func applicationSignificantTimeChange(_ application: UIApplication) {
        delegates.forEach{ $0.applicationSignificantTimeChange?(application) }
    }
    
    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        delegates.forEach{ $0.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)}
    }
    
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        delegates.forEach{ $0.application?(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler) }
    }
    
    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        for delegate in delegates {
            if delegate.application?(application, continue: userActivity, restorationHandler: restorationHandler) == true {
                return true
            }
        }
        return false
    }
    
    open func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
        UserDefaults.resetStandardUserDefaults()
    }
}
