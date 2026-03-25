import Foundation
import UIKit
import DashX
#if canImport(FirebaseCore)
import FirebaseCore
#endif
#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

@objc(DashXRCTAppDelegate)
open class DashXRCTAppDelegate: RCTDefaultReactNativeFactoryDelegate, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    public var window: UIWindow?
    private var reactNativeFactory: RCTReactNativeFactory?

    /// The React Native module name. Defaults to "main". Override to match your app's registered component name.
    open var moduleName: String { "main" }

    // MARK: - UIApplicationDelegate

    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
        #if canImport(FirebaseMessaging)
        Messaging.messaging().delegate = self
        #endif

        UNUserNotificationCenter.current().delegate = self

        DashX.requestNotificationPermission { authorizationStatus in
            switch authorizationStatus {
            case .authorized:
                print("[DashX] Permission authorized — calling registerForRemoteNotifications")
                DashXLog.d(tag: #function, "permission authorized to receive push notifications")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            default:
                print("[DashX] Permission denied")
                DashXLog.d(tag: #function, "permission denied to receive push notifications")
            }
        }

        let factory = RCTReactNativeFactory(delegate: self)
        reactNativeFactory = factory

        window = UIWindow(frame: UIScreen.main.bounds)
        factory.startReactNative(withModuleName: moduleName, in: window, launchOptions: launchOptions)

        return true
    }

    // MARK: - APNS Token Management

    open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("[DashX] Failed to register for remote notifications: \(error.localizedDescription)")
        DashXLog.d(tag: #function, "Unable to register for remote notifications: \(error.localizedDescription)")
    }

    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("[DashX] Received APNS token — forwarding to Firebase")
        #if canImport(FirebaseMessaging)
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
        Messaging.messaging().token { token, error in
            print("[DashX] FCM token callback — token: \(token ?? "nil"), error: \(error?.localizedDescription ?? "none")")
            if let token = token {
                DashX.setFCMToken(to: token)
            }
        }
        #endif
    }

    // MARK: - Universal Links

    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        DashX.handleUserActivity(userActivity: userActivity)
        return true
    }

    // MARK: - Push Notifications

    open func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let message = notification.request.content.userInfo

        #if canImport(FirebaseMessaging)
        Messaging.messaging().appDidReceiveMessage(message)
        #endif

        DashX.trackMessage(message: message, event: .delivered)

        DashXEventEmitter.instance.dispatch(name: "messageReceived", body: bridgeSafePayload(from: message))

        completionHandler(notificationDeliveredInForeground(message: message))
    }

    open func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let message = response.notification.request.content.userInfo

        #if canImport(FirebaseMessaging)
        Messaging.messaging().appDidReceiveMessage(message)
        #endif

        DashXEventEmitter.instance.dispatch(name: "messageReceived", body: bridgeSafePayload(from: message))

        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            DashX.trackMessage(message: message, event: .dismissed)
        } else {
            DashX.trackMessage(message: message, event: .clicked)

            if let url = message.dashxNotificationUrl() {
                handleLink(url: url)
            } else {
                notificationClicked(message: message, actionIdentifier: response.actionIdentifier)
            }
        }

        completionHandler()
    }

    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        #if canImport(FirebaseMessaging)
        Messaging.messaging().appDidReceiveMessage(userInfo)
        #endif

        DashXEventEmitter.instance.dispatch(name: "messageReceived", body: bridgeSafePayload(from: userInfo))

        guard let dashxData = userInfo.dashxNotificationData() else {
            DashXLog.d(tag: #function, "Unable to parse DashX notification data")
            completionHandler(.failed)
            return
        }

        let notificationContent = UNMutableNotificationContent()
        notificationContent.sound = UNNotificationSound.default
        notificationContent.title = dashxData.title
        notificationContent.body = dashxData.body
        notificationContent.userInfo = userInfo
        notificationContent.categoryIdentifier = Constants.DASHX_NOTIFICATION_CATEGORY_IDENTIFIER

        var notificationActions: [UNNotificationAction] = []

        if let actionButtons = dashxData.actionButtons {
            for button in actionButtons {
                notificationActions.append(
                    UNNotificationAction(
                        identifier: button.identifier,
                        title: button.label,
                        options: [.foreground]
                    )
                )
            }
        }

        let notificationCategory = UNNotificationCategory(
            identifier: Constants.DASHX_NOTIFICATION_CATEGORY_IDENTIFIER,
            actions: notificationActions,
            intentIdentifiers: [],
            options: .customDismissAction
        )

        UNUserNotificationCenter.current().setNotificationCategories([notificationCategory])

        if let imagePath = dashxData.image,
           let imageURL = URL(string: imagePath)
        {
            createNotificationWithImage(id: dashxData.id, imageURL: imageURL, content: notificationContent)
        } else {
            createNotification(id: dashxData.id, content: notificationContent)
        }

        completionHandler(.newData)
    }

    // MARK: - Override points

    open func notificationDeliveredInForeground(message: [AnyHashable: Any]) -> UNNotificationPresentationOptions { return [.banner, .sound] }

    open func notificationClicked(message: [AnyHashable: Any], actionIdentifier: String) {}

    open func handleLink(url: URL) {}

    // MARK: - Helpers

    private func bridgeSafePayload(from userInfo: [AnyHashable: Any]) -> [String: Any] {
        userInfo.reduce(into: [String: Any]()) { result, pair in
            let key = String(describing: pair.key)
            let value = pair.value
            if let str = value as? String {
                result[key] = str
            } else if let num = value as? NSNumber {
                result[key] = num
            } else if let dict = value as? [AnyHashable: Any] {
                result[key] = bridgeSafePayload(from: dict)
            } else if let arr = value as? [Any] {
                result[key] = arr.map { item -> Any in
                    if let str = item as? String { return str }
                    if let num = item as? NSNumber { return num }
                    if let d = item as? [AnyHashable: Any] { return bridgeSafePayload(from: d) }
                    if let a = item as? [Any] {
                        return a.map { sub -> Any in
                            if let s = sub as? String { return s }
                            if let n = sub as? NSNumber { return n }
                            if let sd = sub as? [AnyHashable: Any] { return bridgeSafePayload(from: sd) }
                            return "\(sub)"
                        }
                    }
                    return "\(item)"
                }
            } else {
                result[key] = "\(value)"
            }
        }
    }
}

extension DashXRCTAppDelegate {
    private func createNotification(id: String, content: UNMutableNotificationContent) {
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                DashXLog.d(tag: #function, "Failed to schedule notification request: \(error.localizedDescription)")
            } else {
                DashXLog.d(tag: #function, "Notification request added successfully.")
            }
        }
    }

    private func createNotificationWithImage(id: String,
                                             imageURL: URL,
                                             content: UNMutableNotificationContent)
    {
        let task = URLSession.shared.downloadTask(with: imageURL) { location, _, error in
            guard let location = location, error == nil else {
                return
            }

            let tmpDirectoryURL = FileManager.default.temporaryDirectory
            let uuid = UUID().uuidString
            let tmpFileURL = tmpDirectoryURL.appendingPathComponent(uuid + ".png")

            do {
                try FileManager.default.moveItem(at: location, to: tmpFileURL)

                let attachment = try UNNotificationAttachment(identifier: "\(id)-attachment", url: tmpFileURL, options: nil)
                content.attachments = [attachment]
                self.createNotification(id: id, content: content)
            } catch {
                DashXLog.d(tag: #function, "Error moving file: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}

#if canImport(FirebaseMessaging)
extension DashXRCTAppDelegate: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("[DashX] messaging delegate fired, token: \(fcmToken ?? "nil")")
        guard let token = fcmToken else {
            DashXLog.d(tag: #function, "FCM Token is empty")
            return
        }

        DashXLog.d(tag: #function, "FCM Token: \(token)")

        DashX.setFCMToken(to: token)
    }
}
#endif
