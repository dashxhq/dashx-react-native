import Foundation
import UIKit
import UserNotifications
import DashX

@objc(DashXNotificationHandler)
public final class DashXNotificationHandler: NSObject {

    @objc
    public static func handleRemoteNotification(
        userInfo: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
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
    public static func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo

        DashXEventEmitter.instance.dispatch(
            name: "messageReceived",
            body: bridgeSafePayload(from: userInfo)
        )

        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            DashX.trackMessage(message: userInfo, event: .dismissed)
        } else {
            DashX.trackMessage(message: userInfo, event: .clicked)
        }
    }

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
