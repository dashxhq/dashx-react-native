import Foundation

@objc(DashXAppDelegate)
class DashXAppDelegate: NSObject {
    static func swizzleDidReceiveRemoteNotificationFetchCompletionHandler() {
        // To remove the warning -[UIApplication delegate] must be called from main thread only
        // and to call the UI controlling method from the main thread, use `DispatchQueue.main.async`
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate
            let appDelegateClass: AnyClass? = object_getClass(appDelegate)

            let originalSelector = #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
            let swizzledSelector = #selector(DashXAppDelegate.self.handleMessage(_:didReceiveRemoteNotification:fetchCompletionHandler:))

            guard let swizzledMethod = class_getInstanceMethod(DashXAppDelegate.self, swizzledSelector) else {
                return
            }

            if let originalMethod = class_getInstanceMethod(appDelegateClass, originalSelector)  {
                // exchange implementation
                method_exchangeImplementations(originalMethod, swizzledMethod)
            } else {
                // add implementation
                class_addMethod(appDelegateClass, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            }
        }
    }

    // Based on - https://firebase.google.com/docs/cloud-messaging/ios/receive
    @objc
    func handleMessage(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DashXLog.d(tag: #function, "Received APN: \(userInfo)")

        let state = UIApplication.shared.applicationState
        // Do Nothing when app is in foreground
        if state == .active {
            completionHandler(.noData)
            return
        }

        if let dashx = userInfo["dashx"] as? String {
            let maybeDashxDictionary = dashx.convertToDictionary()

            let notificationContent = UNMutableNotificationContent()
            notificationContent.sound = UNNotificationSound.default

            if let parsedDashxDictionary = maybeDashxDictionary {
                guard let identifier = parsedDashxDictionary["id"] as? String else {
                    completionHandler(.newData)
                    // Do not handle non-DashX notifications
                    return
                }

                if let parsedTitle = parsedDashxDictionary["title"] as? String {
                    notificationContent.title = parsedTitle
                }

                if let parsedBody = parsedDashxDictionary["body"] as? String {
                    notificationContent.body = parsedBody
                }

                let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: nil)
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.add(request)

                let data = ["data": userInfo]
                DashXEventEmitter.instance.dispatch(name: "messageReceived", body: data)
            }
        }

        completionHandler(.newData)
    }
}
