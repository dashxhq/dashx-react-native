import Foundation
import DashX

@objc(DashXReactNative)
class DashXReactNative: RCTEventEmitter {
    override init() {
        super.init()
        DashXEventEmitter.instance.registerEventEmitter(eventEmitter: self)
        DashX.linkHandler = { url in
            DashXEventEmitter.instance.dispatch(name: "linkReceived", body: url.absoluteString)
        }
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

    override func supportedEvents() -> [String] {
        return ["messageReceived", "linkReceived"]
    }

    @objc(configure:)
    func configure(_ options: NSDictionary) {
        guard let publicKey = options["publicKey"] as? String, !publicKey.isEmpty else {
            return
        }
        let baseURI = options["baseURI"] as? String
        let targetEnvironment = options["targetEnvironment"] as? String

        DashX.configure(
            withPublicKey: publicKey,
            baseURI: baseURI,
            targetEnvironment: targetEnvironment
        )
    }

    @objc(identify:)
    func identify(_ options: NSDictionary) {
        let stringOptions = (options as? [String: Any])?.compactMapValues { ($0 as? CustomStringConvertible)?.description } ?? [:]
        try? DashX.identify(options: stringOptions)
    }

    @objc(setIdentity:token:)
    func setIdentity(_ uid: NSString?, _ token: NSString?) {
        DashX.setIdentity(uid: uid as String?, token: token as String?)
    }

    @objc
    func reset() {
        DashX.reset()
    }

    @objc(track:data:)
    func track(_ event: String, _ data: NSDictionary?) {
        DashX.track(event, withData: data as? [String: Any])
    }

    @objc(screen:data:)
    func screen(_ screenName: String, _ data: NSDictionary?) {
        DashX.screen(screenName, withData: data as? [String: Any])
    }

    @objc(fetchRecord:options:resolve:reject:)
    func fetchRecord(_ urn: String, options: NSDictionary?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DashXClient.instance.fetchRecord(
            urn: urn,
            preview: options?["preview"] as? Bool,
            language: options?["language"] as? String,
            fields: options?["fields"] as? [[String: Any]],
            include: options?["include"] as? [[String: Any]],
            exclude: options?["exclude"] as? [[String: Any]]
        ) { result in
            switch result {
            case .success(let record): resolve(record)
            case .failure(let error): reject("EUNSPECIFIED", error.localizedDescription, error)
            }
        }
    }

    @objc(searchRecords:options:resolve:reject:)
    func searchRecords(_ resource: String, options: NSDictionary?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DashXClient.instance.searchRecords(
            resource: resource,
            filter: options?["filter"] as? [String: Any],
            order: options?["order"] as? [[String: Any]],
            limit: options?["limit"] as? Int,
            page: options?["page"] as? Int,
            preview: options?["preview"] as? Bool,
            language: options?["language"] as? String,
            fields: options?["fields"] as? [[String: Any]],
            include: options?["include"] as? [[String: Any]],
            exclude: options?["exclude"] as? [[String: Any]]
        ) { result in
            switch result {
            case .success(let records): resolve(records)
            case .failure(let error): reject("EUNSPECIFIED", error.localizedDescription, error)
            }
        }
    }

    @objc(fetchStoredPreferences:reject:)
    func fetchStoredPreferences(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DashXClient.instance.fetchStoredPreferences { result in
            switch result {
            case .success(let prefs): resolve(prefs)
            case .failure(let error): reject("EUNSPECIFIED", error.localizedDescription, error)
            }
        }
    }

    @objc(saveStoredPreferences:resolve:reject:)
    func saveStoredPreferences(_ preferenceData: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        guard let dict = preferenceData as? [String: Any] else {
            reject("EINVAL", "preferenceData must be a plain object", nil)
            return
        }
        DashXClient.instance.saveStoredPreferences(preferenceData: dict) { result in
            switch result {
            case .success(let success): resolve(success)
            case .failure(let error): reject("EUNSPECIFIED", error.localizedDescription, error)
            }
        }
    }

    @objc
    func subscribe() {
        DashX.subscribe()
    }

    @objc
    func unsubscribe() {
        DashX.unsubscribe()
    }

    @objc(setLogLevel:)
    func setLogLevel(_ level: Double) {
        let logLevel = DashXLog.LogLevel(rawValue: Int(level)) ?? DashXLog.LogLevel.off
        DashXLog.setLogLevel(to: logLevel)
    }

    @objc(uploadAsset:resource:attribute:resolve:reject:)
    func uploadAsset(_ filePath: String, resource: String, attribute: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let fileURL = URL(fileURLWithPath: filePath)
        DashXClient.instance.uploadAsset(fileURL: fileURL, resource: resource, attribute: attribute) { result in
            switch result {
            case .success(let assetResponse):
                if let data = try? JSONEncoder().encode(assetResponse),
                   let dict = try? JSONSerialization.jsonObject(with: data) as? NSDictionary {
                    resolve(dict)
                } else {
                    resolve(nil)
                }
            case .failure(let error):
                reject("EUNSPECIFIED", error.localizedDescription, error)
            }
        }
    }

    @objc(fetchAsset:resolve:reject:)
    func fetchAsset(_ assetId: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DashXClient.instance.fetchAsset(assetId: assetId) { result in
            switch result {
            case .success(let assetResponse):
                if let data = try? JSONEncoder().encode(assetResponse),
                   let dict = try? JSONSerialization.jsonObject(with: data) as? NSDictionary {
                    resolve(dict)
                } else {
                    resolve(nil)
                }
            case .failure(let error):
                reject("EUNSPECIFIED", error.localizedDescription, error)
            }
        }
    }

    @objc
    func enableLifecycleTracking() {
        DispatchQueue.main.async { DashX.enableLifecycleTracking() }
    }

    @objc
    func enableAdTracking() {
        DashX.enableAdTracking()
    }

    @objc(processURL:source:forwardToLinkHandler:)
    func processURL(_ url: String, source: NSString?, forwardToLinkHandler: Bool) {
        guard let parsedURL = URL(string: url) else { return }
        DashX.processURL(parsedURL, source: source as String?, forwardToLinkHandler: forwardToLinkHandler)
    }

    @objc(trackNotificationNavigation:notificationId:)
    func trackNotificationNavigation(_ action: NSDictionary?, notificationId: NSString?) {
        var navigationAction: NavigationAction? = nil
        if let action = action, let type = action["type"] as? String {
            switch type {
            case "deepLink":
                if let urlString = action["url"] as? String, let url = URL(string: urlString) {
                    navigationAction = .deepLink(url: url)
                }
            case "screen":
                if let name = action["name"] as? String {
                    navigationAction = .screen(name: name, data: action["data"] as? [String: String])
                }
            case "richLanding":
                if let urlString = action["url"] as? String, let url = URL(string: urlString) {
                    navigationAction = .richLanding(url: url)
                }
            case "clickAction":
                if let actionStr = action["action"] as? String {
                    navigationAction = .clickAction(action: actionStr)
                }
            default:
                break
            }
        }
        DashX.trackNotificationNavigation(navigationAction, notificationId: notificationId as String?)
    }

    @objc(requestNotificationPermission:reject:)
    func requestNotificationPermission(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DashX.requestNotificationPermission { status in resolve(status.rawValue) }
    }

    @objc(getNotificationPermissionStatus:reject:)
    func getNotificationPermissionStatus(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DashX.getNotificationPermissionStatus { status in resolve(status.rawValue) }
    }
}
