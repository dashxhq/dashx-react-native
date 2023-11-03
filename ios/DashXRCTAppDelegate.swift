import FirebaseCore
import FirebaseMessaging
import Foundation
import UIKit
import DashX

@objc(DashXRCTAppDelegate)
open class DashXRCTAppDelegate: RCTAppDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    // MARK: Getters
    private var app: UIApplication = .shared

    // MARK: Init

    public override init() {
        super.init()

        UNUserNotificationCenter.current().delegate = self

        // Register to ensure device token can be fetched
        app.registerForRemoteNotifications()
    }

    // MARK: MessagingDelegate

    open override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        // Requesting Push Notifications Permission
        DashX.requestNotificationPermission { authorizationStatus in
            switch authorizationStatus {
            case .authorized:
                DashXLog.d(tag: #function, "permission authorized to receive push notifications")
            default:
                DashXLog.d(tag: #function, "permission denied to receive push notifications")
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - APNS Token Management

    public override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DashXLog.d(tag: #function, "Unable to register for remote notifications: \(error.localizedDescription)")
    }

    public override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            DashXLog.d(tag: #function, "FCM Token is empty")
            return
        }

        DashXLog.d(tag: #function, "FCM Token: \(token)")

        DashX.setFCMToken(to: token)
    }

    // MARK: - Push Notifications

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let message = notification.request.content.userInfo

        // Pass notification reciept information to Firebase
        Messaging.messaging().appDidReceiveMessage(message)

        DashX.trackNotification(message: message, event: .delivered)

        let presentationOptions = notificationDeliveredInForeground(message: message)

        completionHandler(presentationOptions)
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let message = response.notification.request.content.userInfo

        // Pass notification reciept information to Firebase
        Messaging.messaging().appDidReceiveMessage(message)

        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            DashX.trackNotification(message: message, event: .dismissed)
        } else {
            DashX.trackNotification(message: message, event: .clicked)

            if let url = message.dashxNotificationUrl() {
                handleLink(url: url)
            } else {
                notificationClicked(message: message, actionIdentifier: response.actionIdentifier)
            }
        }

        completionHandler()
    }

    public override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Pass notification reciept information to Firebase
        Messaging.messaging().appDidReceiveMessage(userInfo)

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

    // MARK: - Push Notifications handlers

    open func notificationDeliveredInForeground(message: [AnyHashable: Any]) -> UNNotificationPresentationOptions { return [] }

    open func notificationClicked(message: [AnyHashable: Any], actionIdentifier: String) {}

    open func handleLink(url: URL) {}
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

            // Create a temporary file URL to save the downloaded image
            let tmpDirectoryURL = FileManager.default.temporaryDirectory
            let uuid = UUID().uuidString
            let tmpFileURL = tmpDirectoryURL.appendingPathComponent(uuid + ".png")

            do {
                // Move the downloaded file to the temporary file URL
                try FileManager.default.moveItem(at: location, to: tmpFileURL)

                // Create the notification attachment from the temporary file URL
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
