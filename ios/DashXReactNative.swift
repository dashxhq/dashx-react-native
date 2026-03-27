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
    func setIdentity(_ uid: String, _ token: String) {
        DashX.setIdentity(uid: uid, token: token)
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

    @objc(fetchRecord:options:resolver:rejecter:)
    func fetchRecord(_ urn: String, options: NSDictionary?, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
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

    @objc(searchRecords:options:resolver:rejecter:)
    func searchRecords(_ resource: String, options: NSDictionary?, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
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

    @objc(fetchStoredPreferences:rejecter:)
    func fetchStoredPreferences(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DashXClient.instance.fetchStoredPreferences { result in
            switch result {
            case .success(let prefs): resolve(prefs)
            case .failure(let error): reject("EUNSPECIFIED", error.localizedDescription, error)
            }
        }
    }

    @objc(saveStoredPreferences:resolver:rejecter:)
    func saveStoredPreferences(_ preferenceData: NSDictionary, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
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
    func setLogLevel(_ level: Int) {
        let logLevel = DashXLog.LogLevel(rawValue: level) ?? DashXLog.LogLevel.off
        DashXLog.setLogLevel(to: logLevel)
    }

    @objc(uploadAsset:resource:attribute:resolver:rejecter:)
    func uploadAsset(_ filePath: String, resource: String, attribute: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
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

    @objc(fetchAsset:resolver:rejecter:)
    func fetchAsset(_ assetId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
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

    @objc(requestNotificationPermission:rejecter:)
    func requestNotificationPermission(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DashX.requestNotificationPermission { status in resolve(status.rawValue) }
    }

    @objc(getNotificationPermissionStatus:rejecter:)
    func getNotificationPermissionStatus(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DashX.getNotificationPermissionStatus { status in resolve(status.rawValue) }
    }
}
