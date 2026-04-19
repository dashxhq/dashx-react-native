import Foundation
import UIKit
import UserNotifications
import DashX
import FirebaseMessaging

/// The result of handling a notification response.
/// Consumers can use `url` to navigate and `actionIdentifier` for custom action handling.
@objc(DashXNotificationResponseResult)
public final class DashXNotificationResponseResult: NSObject {
    @objc public let userInfo: [AnyHashable: Any]
    @objc public let actionIdentifier: String
    /// The DashX notification URL, if present in the payload.
    @objc public let url: URL?
    /// The resolved navigation intent for the tap / action button.
    /// Non-@objc (the enum isn't representable in Obj-C); read via Swift.
    public let navigationAction: NavigationAction?

    init(userInfo: [AnyHashable: Any], actionIdentifier: String, url: URL?, navigationAction: NavigationAction?) {
        self.userInfo = userInfo
        self.actionIdentifier = actionIdentifier
        self.url = url
        self.navigationAction = navigationAction
    }
}

@objc(DashXNotificationHandler)
public final class DashXNotificationHandler: NSObject {

    @objc
    public static func handleRemoteNotification(
        userInfo: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Messaging.messaging().appDidReceiveMessage(userInfo)

        DashXEventEmitter.instance.dispatch(
            name: "messageReceived",
            body: bridgeSafePayload(from: userInfo)
        )

        guard let dashxData = userInfo.dashxNotificationData() else {
            completionHandler(.noData)
            return
        }

        DashX.trackMessage(message: userInfo, event: .delivered)

        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = dashxData.title
        content.body = dashxData.body
        content.userInfo = userInfo
        content.categoryIdentifier = Constants.DASHX_NOTIFICATION_CATEGORY_IDENTIFIER

        var actions: [UNNotificationAction] = []
        if let actionButtons = dashxData.actionButtons {
            for button in actionButtons {
                actions.append(
                    UNNotificationAction(
                        identifier: button.identifier,
                        title: button.label,
                        options: [.foreground]
                    )
                )
            }
        }

        let category = UNNotificationCategory(
            identifier: Constants.DASHX_NOTIFICATION_CATEGORY_IDENTIFIER,
            actions: actions,
            intentIdentifiers: [],
            options: .customDismissAction
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])

        if let imagePath = dashxData.image, let imageURL = URL(string: imagePath) {
            createNotificationWithImage(id: dashxData.id, imageURL: imageURL, content: content)
        } else {
            createNotification(id: dashxData.id, content: content)
        }

        completionHandler(.newData)
    }

    @objc
    @discardableResult
    public static func handleNotificationResponse(_ response: UNNotificationResponse) -> DashXNotificationResponseResult {
        let userInfo = response.notification.request.content.userInfo

        Messaging.messaging().appDidReceiveMessage(userInfo)

        DashXEventEmitter.instance.dispatch(
            name: "messageReceived",
            body: bridgeSafePayload(from: userInfo)
        )

        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            DashX.trackMessage(message: userInfo, event: .dismissed)
        } else {
            DashX.trackMessage(message: userInfo, event: .clicked)
        }

        let notificationUrl = userInfo.dashxNotificationUrl()
        let dashxData = userInfo.dashxNotificationData()
        let navigationAction = dashxData?.navigationAction(forActionIdentifier: response.actionIdentifier)

        if response.actionIdentifier != UNNotificationDismissActionIdentifier {
            DashXEventEmitter.instance.dispatch(
                name: "notificationClicked",
                body: [
                    "notification": bridgeSafePayload(from: userInfo),
                    "action": jsonDictionary(from: navigationAction) ?? NSNull(),
                    "actionIdentifier": response.actionIdentifier,
                ]
            )
        }

        return DashXNotificationResponseResult(
            userInfo: userInfo,
            actionIdentifier: response.actionIdentifier,
            url: notificationUrl,
            navigationAction: navigationAction
        )
    }

    // MARK: - Device Token

    /// Bridges the APNS device token to Firebase Cloud Messaging and registers
    /// the FCM token with DashX. Call this from
    /// `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`.
    @objc
    public static func handleDeviceToken(_ deviceToken: Data) {
        // Force the APNs environment explicitly rather than using `.unknown`
        // (auto-detect). Firebase's auto-detection reads the token's aps
        // entitlement from the signed binary and sometimes mis-tags dev
        // builds as production, producing an FCM token whose pushes silently
        // fail at APNs with 410 Unregistered.
        #if DEBUG
        Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
        #else
        Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
        #endif
        Messaging.messaging().token { token, error in
            if let token = token {
                DashX.setFCMToken(to: token)
            }
        }
    }

    // MARK: - Foreground Notification

    /// Handles a notification that arrived while the app is in the foreground.
    /// Tracks the delivery event, emits `messageReceived` to JS, forwards to
    /// Firebase analytics, and presents the notification as a banner with sound.
    /// Call this from `userNotificationCenter(_:willPresent:withCompletionHandler:)`.
    @objc
    public static func handleForegroundNotification(
        _ notification: UNNotification,
        completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        Messaging.messaging().appDidReceiveMessage(userInfo)

        DashX.trackMessage(message: userInfo, event: .delivered)

        DashXEventEmitter.instance.dispatch(
            name: "messageReceived",
            body: bridgeSafePayload(from: userInfo)
        )

        completionHandler([.banner, .sound])
    }

    // MARK: - Private Helpers

    private static func createNotification(id: String, content: UNMutableNotificationContent) {
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                DashXLog.d(tag: #function, "Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    private static func createNotificationWithImage(
        id: String,
        imageURL: URL,
        content: UNMutableNotificationContent
    ) {
        let task = URLSession.shared.downloadTask(with: imageURL) { location, _, error in
            guard let location = location, error == nil else {
                createNotification(id: id, content: content)
                return
            }

            let tmpDir = FileManager.default.temporaryDirectory
            let tmpFile = tmpDir.appendingPathComponent(UUID().uuidString + ".png")

            do {
                try FileManager.default.moveItem(at: location, to: tmpFile)
                let attachment = try UNNotificationAttachment(
                    identifier: "\(id)-attachment",
                    url: tmpFile,
                    options: nil
                )
                content.attachments = [attachment]
                createNotification(id: id, content: content)
            } catch {
                createNotification(id: id, content: content)
            }
        }
        task.resume()
    }

    /// Serializes a ``NavigationAction`` into the JS-bridge shape mirrored by
    /// `NavigationAction` in `index.d.ts`. Returns `nil` for `nil` input.
    private static func jsonDictionary(from action: NavigationAction?) -> [String: Any]? {
        guard let action else { return nil }
        switch action {
        case .deepLink(let url):
            return ["type": "deepLink", "url": url.absoluteString]
        case .screen(let name, let data):
            var dict: [String: Any] = ["type": "screen", "name": name]
            if let data { dict["data"] = data }
            return dict
        case .richLanding(let url):
            return ["type": "richLanding", "url": url.absoluteString]
        case .clickAction(let actionString):
            return ["type": "clickAction", "action": actionString]
        }
    }

    private static func bridgeSafePayload(from userInfo: [AnyHashable: Any]) -> [String: Any] {
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
                    return "\(item)"
                }
            } else {
                result[key] = "\(value)"
            }
        }
    }
}
