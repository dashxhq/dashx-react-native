import Foundation

@objc(DashXApplicationLifecycleCallbacks)
class DashXApplicationLifecycleCallbacks: NSObject {
    static let instance = DashXApplicationLifecycleCallbacks()
    let dashXClient = DashXClient.instance
    var startSession: Double?

    func enable() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: #selector(appBackgrounded), name: UIApplication.willResignActiveNotification, object: nil)

        notificationCenter.addObserver(self, selector: #selector(appResumed), name: UIApplication.willEnterForegroundNotification, object: nil)

        NSSetUncaughtExceptionHandler { exception in
            DashXClient.instance.track(Constants.INTERNAL_EVENT_APP_CRASHED, withData: [ "exception": exception.reason ])
        }

        appOpened()
    }

    func getAppBuildInfo() -> [String: Any] {
        let currentRelease = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let currentBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return [ "version": currentRelease, "build": currentBuild ]
    }

    @objc
    func appBackgrounded() {
        let sessionLength = Date.timeIntervalSinceReferenceDate - startSession!

        dashXClient.track(Constants.INTERNAL_EVENT_APP_BACKGROUNDED, withData: [ "session_length": sessionLength ])
    }

    @objc
    func appOpened() {
        startSession = Date.timeIntervalSinceReferenceDate
        let defaults = UserDefaults.standard
        let appVersionKey = Constants.USER_PREFERENCES_KEY_BUILD
        let appBuildInfo = getAppBuildInfo()
        let previousBuild = defaults.string(forKey: appVersionKey)
        let currentBuild = appBuildInfo["build"] as! String

        if previousBuild == nil {
            dashXClient.track(Constants.INTERNAL_EVENT_APP_INSTALLED, withData: appBuildInfo as NSDictionary)
            defaults.set(currentBuild, forKey: appVersionKey)
            defaults.synchronize()
        } else if previousBuild == currentBuild {
            dashXClient.track(Constants.INTERNAL_EVENT_APP_OPENED, withData: appBuildInfo as NSDictionary)
        } else {
            dashXClient.track(Constants.INTERNAL_EVENT_APP_UPDATED, withData: appBuildInfo as NSDictionary)
            defaults.set(currentBuild, forKey: appVersionKey)
            defaults.synchronize()
        }
    }

    @objc
    func appResumed() {
        startSession = Date.timeIntervalSinceReferenceDate
        let properties = getAppBuildInfo().merging([ "from_background": true ]) { (current, _) in current }

        dashXClient.track(Constants.INTERNAL_EVENT_APP_OPENED, withData: properties as NSDictionary)
    }
}
