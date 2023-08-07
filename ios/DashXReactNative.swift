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

    @objc
    func configure(_ options: NSDictionary) {
        let publicKey = options["publicKey"] as! String,
            baseURI = options["baseURI"] as? String,
            targetEnvironment = options["targetEnvironment"] as? String

        DashX.configure(
            withPublicKey: publicKey,
            baseURI: baseURI,
            targetEnvironment: targetEnvironment
        )
    }

    @objc
    func identify(_ options: NSDictionary) {
        try? DashX.identify(withOptions: options)
    }

    @objc
    func setIdentity(_ uid: String, _ token: String) {
        DashX.setIdentity(uid: uid, token: token)
    }

    @objc
    func reset() {
        DashX.reset()
    }

    @objc
    func track(_ event: String, _ data: NSDictionary?) {
        DashX.track(event, withData: data)
    }

    @objc
    func screen(_ screenName: String, _ data: NSDictionary?) {
        DashX.screen(screenName, withData: data)
    }

    @objc
    func fetchStoredPreferences(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DashX.fetchStoredPreferences(
            successCallback: CBU.resolveToSuccessCallback(resolve),
            failureCallback: CBU.rejectToFailureCallback(reject)
        )
    }

    @objc
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
