import Foundation
import DashX

typealias CBU = CallbackUtils

@objc(DashXReactNative)
class DashXReactNative: RCTEventEmitter {
    override init() {
        super.init()
        DashXEventEmitter.instance.registerEventEmitter(eventEmitter: self)
    }

    override func supportedEvents() -> [String] {
        return ["messageReceived"]
    }

    @objc
    func configure(_ options: NSDictionary) {
        let publicKey = options["publicKey"] as! String,
            baseURI = options["baseURI"] as? String,
            targetEnvironment = options["targetEnvironment"] as? String

        DashX.configure(withPublicKey: publicKey,
                              baseURI: baseURI,
                              targetEnvironment: targetEnvironment)
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
