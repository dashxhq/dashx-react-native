import Foundation

struct Constants {
    static let PACKAGE_NAME = "com.dashx.sdk"
    static let USER_PREFERENCES_KEY_ANONYMOUS_UID = "\(PACKAGE_NAME).anonymous_uid"
    static let USER_PREFERENCES_KEY_DEVICE_TOKEN = "\(PACKAGE_NAME).device_token"
    static let USER_PREFERENCES_KEY_BUILD = "\(PACKAGE_NAME).build"
    static let INTERNAL_EVENT_APP_INSTALLED = "Application Installed"
    static let INTERNAL_EVENT_APP_UPDATED = "Application Updated"
    static let INTERNAL_EVENT_APP_OPENED = "Application Opened"
    static let INTERNAL_EVENT_APP_BACKGROUNDED = "Application Backgrounded"
    static let INTERNAL_EVENT_APP_CRASHED = "Application Crashed"
    static let INTERNAL_EVENT_APP_SCREEN_VIEWED = "Screen Viewed"
}
