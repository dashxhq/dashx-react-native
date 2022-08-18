import Foundation
import DashX

typealias CBU = CallbackUtils

@objc(DashXReactNative)
class DashXReactNative: RCTEventEmitter {
    private var dashXClient = DashX

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
        
        dashXClient.configure(withPublicKey: publicKey,
                              baseURI: baseURI,
                              targetEnvironment: targetEnvironment)
    }

    @objc(identify:)
    func identify(_ options: NSDictionary) {
        try? dashXClient.identify(withOptions: options)
    }

    @objc(setIdentity:token:)
    func setIdentity(_ uid: String, _ token: String) {
        dashXClient.setIdentity(uid: uid, token: token)
    }

    @objc
    func reset() {
      dashXClient.reset()
    }

    @objc(track:data:)
    func track(_ event: String, _ data: NSDictionary?) {
        dashXClient.track(event, withData: data)
    }

    @objc(screen:data:)
    func screen(_ screenName: String, _ data: NSDictionary?) {
      dashXClient.screen(screenName, withData: data)
    }

    @objc(searchContent:options:resolver:rejecter:)
    func searchContent(_ contentType: String, _ options: NSDictionary?, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let optionsDictionary = options as? [String: Any]

        dashXClient.searchContent(
            contentType: contentType,
            returnType: optionsDictionary?["returnType"] as! String? ?? "all",
            filter: optionsDictionary?["filter"] as! NSDictionary?,
            order: optionsDictionary?["order"] as! NSDictionary?,
            limit: optionsDictionary?["limit"] as! Int?,
            preview: optionsDictionary?["preview"] as! Bool?,
            language: optionsDictionary?["language"] as! String?,
            fields: optionsDictionary?["fields"] as! [String]?,
            include: optionsDictionary?["include"] as! [String]?,
            exclude: optionsDictionary?["exclude"] as! [String]?,
            successCallback: CBU.resolveToSuccessCallback(resolve),
            failureCallback: CBU.rejectToFailureCallback(reject)
        )
    }

    @objc(fetchContent:options:resolver:rejecter:)
    func fetchContent(_ urn: String, _ options: NSDictionary?, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let optionsDictionary = options as? [String: Any]
        let urnArray = urn.split{$0 == "/"}.map(String.init)

        dashXClient.fetchContent(
            contentType: urnArray[0],
            content: urnArray[1],
            preview: optionsDictionary?["preview"] as! Bool?,
            language: optionsDictionary?["language"] as! String?,
            fields: optionsDictionary?["fields"] as! [String]?,
            include: optionsDictionary?["include"] as! [String]?,
            exclude: optionsDictionary?["exclude"] as! [String]?,
            successCallback: CBU.resolveToSuccessCallback(resolve),
            failureCallback: CBU.rejectToFailureCallback(reject)
        )
    }

    @objc(addItemToCart:pricingId:quantity:reset:custom:resolver:rejecter:)
    func addItemToCart(_ itemId: String, _ pricingId: String, _ quantity: String, _ reset: Bool, _ custom: NSDictionary?, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {

        dashXClient.addItemToCart(
            itemId: itemId,
            pricingId: pricingId,
            quantity: quantity,
            reset: reset,
            custom: custom,
            successCallback: CBU.resolveToSuccessCallback(resolve),
            failureCallback: CBU.rejectToFailureCallback(reject)
        )
    }

    @objc(fetchCart:rejecter:)
    func fetchCart(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {

        dashXClient.fetchCart(
            successCallback: CBU.resolveToSuccessCallback(resolve),
            failureCallback: CBU.rejectToFailureCallback(reject)
        )
    }

    @objc(fetchStoredPreferences:rejecter:)
    func fetchStoredPreferences(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {

        dashXClient.fetchStoredPreferences(
            successCallback: CBU.resolveToSuccessCallback(resolve),
            failureCallback: CBU.rejectToFailureCallback(reject)
        )
    }

    @objc(uploadExternalAsset:externalColumnId:resolver:rejecter:)
    func uploadExternalAsset(_ file: NSDictionary, _ externalColumnId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if let fileDictionary = file as? [String: Any], let fileURI = fileDictionary["uri"] as? String {
          // Remove unnecessary file:/// prefix for correct URL resolution
          let normalizedURI = fileURI.replacingOccurrences(of: "file:///", with: "")
          
          dashXClient.uploadExternalAsset(
              fileURL: URL(fileURLWithPath: normalizedURI),
              externalColumnId: externalColumnId,
              successCallback: CBU.resolveToSuccessCallback(resolve),
              failureCallback: CBU.rejectToFailureCallback(reject)
          )
        }
    }

    @objc(externalAsset:resolver:rejecter:)
    func externalAsset(_ assetId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
      dashXClient.externalAsset(
        assetId: assetId,
        successCallback: CBU.resolveToSuccessCallback(resolve),
        failureCallback: CBU.rejectToFailureCallback(reject)
      )
    }

    @objc
    func subscribe() {
      dashXClient.subscribe()
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
