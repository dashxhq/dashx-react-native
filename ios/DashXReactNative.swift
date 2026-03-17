import Foundation
import DashX

typealias CBU = CallbackUtils

@objc(DashXReactNative)
class DashXReactNative: RCTEventEmitter {
    override init() {
        super.init()
        DashXEventEmitter.instance.registerEventEmitter(eventEmitter: self)
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

    override func supportedEvents() -> [String] {
        return ["messageReceived"]
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
        try? DashX.identify(withOptions: options)
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
        DashX.track(event, withData: data)
    }

    @objc(screen:data:)
    func screen(_ screenName: String, _ data: NSDictionary?) {
        DashX.screen(screenName, withData: data)
    }

    @objc(fetchRecord:options:resolver:rejecter:)
    func fetchRecord(_ urn: String, options: NSDictionary?, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        reject("EUNIMPLEMENTED", "fetchRecord is not yet implemented on iOS", nil)
    }

    @objc(searchRecords:options:resolver:rejecter:)
    func searchRecords(_ resource: String, options: NSDictionary?, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        reject("EUNIMPLEMENTED", "searchRecords is not yet implemented on iOS", nil)
    }

    @objc(fetchStoredPreferences:rejecter:)
    func fetchStoredPreferences(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DashX.fetchStoredPreferences(
            successCallback: CBU.resolveToSuccessCallback(resolve),
            failureCallback: CBU.rejectToFailureCallback(reject)
        )
    }

    @objc(saveStoredPreferences:resolve:rejecter:)
    func saveStoredPreferences(_ preferenceData: NSDictionary, _ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DashX.saveStoredPreferences(
            preferenceData: preferenceData,
            successCallback: CBU.resolveToSuccessCallback(resolve),
            failureCallback: CBU.rejectToFailureCallback(reject)
        )
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
}

class CallbackUtils {
    static func resolveToSuccessCallback(_ resolve: @escaping RCTPromiseResolveBlock) -> SuccessCallback {
        return resolve
    }

    static func rejectToFailureCallback(_ reject: @escaping RCTPromiseRejectBlock) -> FailureCallback {
        let result: FailureCallback = { (error) in
            reject("\((error as NSError).code)", error.localizedDescription, error)
        }

        return result
    }
}
