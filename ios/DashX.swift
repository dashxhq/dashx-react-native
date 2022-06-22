import Foundation
import FirebaseMessaging

@objc(DashX)
class DashX: RCTEventEmitter {
    private var dashXClient = DashXClient.instance

    override init() {
        super.init()
        DashXEventEmitter.instance.registerEventEmitter(eventEmitter: self)
    }

    @objc
    func setLogLevel(_ logLevel: Int) {
        DashXLog.setLogLevel(to: logLevel)
    }

    override func supportedEvents() -> [String] {
        return ["messageReceived"]
    }

    @objc
    func setup(_ options: NSDictionary?) {
        ConfigInterceptor.shared.publicKey = options?.value(forKey: "publicKey") as? String

        DashXAppDelegate.swizzleDidReceiveRemoteNotificationFetchCompletionHandler()

        if let baseUri = options?.value(forKey: "baseUri") {
            Network.shared.setBaseUri(to: baseUri as! String)
        }

        if let targetInstallation = options?.value(forKey: "targetInstallation") {
            dashXClient.setTargetInstallation(to: targetInstallation as! String)
        }

        if let targetEnvironment = options?.value(forKey: "targetEnvironment") {
            dashXClient.setTargetEnvironment(to: targetEnvironment as! String)
        }

        if let trackAppLifecycleEvents = options?.value(forKey: "trackAppLifecycleEvents"), trackAppLifecycleEvents as! Bool {
            DashXApplicationLifecycleCallbacks.instance.enable()
        }

        if let trackScreenViews = options?.value(forKey: "trackScreenViews"), trackScreenViews as! Bool {
            UIViewController.swizzle()
        }

        // Based on https://firebase.google.com/docs/cloud-messaging/ios/client#access_the_registration_token
        Messaging.messaging().token { token, error in
            if let error = error {
                DashXLog.d(tag: #function, "Error fetching FCM registration token: \(error)")
            } else if let token = token {
                DashXLog.d(tag: #function, "Firebase initialised with: \(token)")
                self.dashXClient.setDeviceToken(to: token)
            }
        }
    }

    @objc(identify:options:)
    func identify(_ uid: String?, _ options: NSDictionary?) {
        try? dashXClient.identify(uid, withOptions: options)
    }

    @objc
    func setIdentityToken(_ identityToken: String) {
        dashXClient.setIdentityToken(to: identityToken)
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
            contentType,
            optionsDictionary?["returnType"] as! String? ?? "all",
            optionsDictionary?["filter"] as! NSDictionary?,
            optionsDictionary?["order"] as! NSDictionary?,
            optionsDictionary?["limit"] as! Int?,
            optionsDictionary?["preview"] as! Bool?,
            optionsDictionary?["language"] as! String?,
            optionsDictionary?["fields"] as! [String]?,
            optionsDictionary?["include"] as! [String]?,
            optionsDictionary?["exclude"] as! [String]?,
            resolve,
            reject
        )
    }

    @objc(fetchContent:options:resolver:rejecter:)
    func fetchContent(_ urn: String, _ options: NSDictionary?, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        let optionsDictionary = options as? [String: Any]
        let urnArray = urn.split{$0 == "/"}.map(String.init)

        dashXClient.fetchContent(
            urnArray[0],
            urnArray[1],
            optionsDictionary?["preview"] as! Bool?,
            optionsDictionary?["language"] as! String?,
            optionsDictionary?["fields"] as! [String]?,
            optionsDictionary?["include"] as! [String]?,
            optionsDictionary?["exclude"] as! [String]?,
            resolve,
            reject
        )
    }

    @objc(addItemToCart:pricingId:quantity:reset:custom:resolver:rejecter:)
    func addItemToCart(_ itemId: String, _ pricingId: String, _ quantity: String, _ reset: Bool, _ custom: NSDictionary?, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {

        dashXClient.addItemToCart(
            itemId,
            pricingId,
            quantity,
            reset,
            custom,
            resolve,
            reject
        )
    }

    @objc(fetchCart:rejecter:)
    func fetchCart(resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {

        dashXClient.fetchCart(
            resolve,
            reject
        )
    }

    @objc
    func subscribe() {
        dashXClient.subscribe()
    }
}
