import Foundation
import Apollo

enum DashXClientError: Error {
    case noArgsInIdentify
}

class DashXClient {
    static let instance = DashXClient()
    private var anonymousUid: String?
    private var uid: String?
    private var deviceToken: String?

    private var mustSubscribe: Bool = false;

    private init() {
        generateAnonymousUid()
    }

    func setDeviceToken(to: String) {
        self.deviceToken = to

        if (self.mustSubscribe) {
          self.subscribe()
        }
    }

    func setTargetEnvironment(to: String) {
        ConfigInterceptor.shared.targetEnvironment = to
    }

    func setTargetInstallation(to: String) {
        ConfigInterceptor.shared.targetInstallation = to
    }

    func setIdentityToken(to: String) {
        ConfigInterceptor.shared.identityToken = to
    }

    private func generateAnonymousUid(withRegenerate: Bool = false) {
        let preferences = UserDefaults.standard
        let anonymousUidKey = Constants.USER_PREFERENCES_KEY_ANONYMOUS_UID

        if !withRegenerate && preferences.object(forKey: anonymousUidKey) != nil {
            self.anonymousUid = preferences.string(forKey: anonymousUidKey) ?? nil
        } else {
            self.anonymousUid = UUID().uuidString
            preferences.set(self.anonymousUid, forKey: anonymousUidKey)
        }
    }
    // MARK: -- identify

    func identify(_ uid: String?, withOptions: NSDictionary?) throws {
        if uid != nil {
            self.uid = uid
            return
        }

        if withOptions == nil {
            throw DashXClientError.noArgsInIdentify
        }

        let optionsDictionary = withOptions as? [String: String]

        self.uid = optionsDictionary?["uid"]

        let identifyAccountInput = DashXGql.IdentifyAccountInput(
            uid: optionsDictionary?["uid"],
            anonymousUid: anonymousUid,
            email: optionsDictionary?["email"],
            phone: optionsDictionary?["phone"],
            name: optionsDictionary?["name"],
            firstName: optionsDictionary?["firstName"],
            lastName: optionsDictionary?["lastName"]
        )

        let identifyAccountMutation = DashXGql.IdentifyAccountMutation(input: identifyAccountInput)

        Network.shared.apollo.perform(mutation: identifyAccountMutation) { result in
          switch result {
          case .success(let graphQLResult):
            DashXLog.d(tag: #function, "Sent identify with \(String(describing: graphQLResult))")
          case .failure(let error):
            DashXLog.d(tag: #function, "Encountered an error during identify(): \(error)")
          }
        }
    }

    func reset() {
        self.uid = nil
        self.generateAnonymousUid(withRegenerate: true)
    }
    // MARK: -- track

    func track(_ event: String, withData: NSDictionary?) {
        let trackEventInput = DashXGql.TrackEventInput(
            event: event,
            accountUid: uid,
            accountAnonymousUid: anonymousUid,
            data: withData as? [String: JSONDecodable?]
        )

        DashXLog.d(tag: #function, "Calling track with \(trackEventInput)")

        let trackEventMutation = DashXGql.TrackEventMutation(input: trackEventInput)

        Network.shared.apollo.perform(mutation: trackEventMutation) { result in
          switch result {
          case .success(let graphQLResult):
            DashXLog.d(tag: #function, "Sent track with \(String(describing: graphQLResult))")
          case .failure(let error):
            DashXLog.d(tag: #function, "Encountered an error during track(): \(error)")
          }
        }
    }

    func screen(_ screenName: String, withData: NSDictionary?) {
        let properties = withData as? [String: Any]

        track(Constants.INTERNAL_EVENT_APP_SCREEN_VIEWED, withData: properties?.merging([ "name": screenName], uniquingKeysWith: { (_, new) in new }) as NSDictionary?)
    }

    // https://stackoverflow.com/a/11197770
    func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }

    // MARK: -- subscribe

    func subscribe() {
        if deviceToken == nil {
            self.mustSubscribe = true
            return
        }

        self.mustSubscribe = false

        let preferences = UserDefaults.standard
        let deviceTokenKey = Constants.USER_PREFERENCES_KEY_DEVICE_TOKEN

        if preferences.string(forKey: deviceTokenKey) == deviceToken {
            DashXLog.d(tag: #function, "Already subscribed: \(String(describing: deviceToken))")
            return
        }
        
        let subscribeContactInput  = DashXGql.SubscribeContactInput(
            accountUid: uid,
            accountAnonymousUid: anonymousUid!,
            name: UIDevice.current.model,
            kind: .ios,
            value: deviceToken!,
            osName: UIDevice.current.systemName,
            osVersion: UIDevice.current.systemVersion,
            deviceModel: getDeviceModel(),
            deviceManufacturer: "Apple"
        )

        DashXLog.d(tag: #function, "Calling subscribe with \(subscribeContactInput)")

        let subscribeContactMutation = DashXGql.SubscribeContactMutation(input: subscribeContactInput)

        Network.shared.apollo.perform(mutation: subscribeContactMutation) { result in
          switch result {
          case .success(let graphQLResult):
              if graphQLResult.data != nil {
                    preferences.set(graphQLResult.data?.subscribeContact.value, forKey: deviceTokenKey)
                    DashXLog.d(tag: #function, "Sent subscribe with \(String(describing: graphQLResult))")
              }
          case .failure(let error):
            DashXLog.d(tag: #function, "Encountered an error during subscribe(): \(error)")
          }
        }
    }
    // MARK: -- content

    func fetchContent(
        _ contentType: String,
        _ content: String,
        _ preview: Bool? = true,
        _ language: String?,
        _ fields: [String]? = [],
        _ include: [String]? = [],
        _ exclude: [String]? = [],
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock
    ) {
        let fetchContentInput  = DashXGql.FetchContentInput(
            contentType: contentType,
            content: content,
            preview: preview,
            language: language,
            fields: fields,
            include: include,
            exclude: exclude
        )

        DashXLog.d(tag: #function, "Calling fetchContent with \(fetchContentInput)")

        let findContentQuery = DashXGql.FetchContentQuery(input: fetchContentInput)

        Network.shared.apollo.fetch(query: findContentQuery, cachePolicy: .returnCacheDataElseFetch) { result in
          switch result {
          case .success(let graphQLResult):
            DashXLog.d(tag: #function, "Sent findContent with \(String(describing: graphQLResult))")
            let content = graphQLResult.data?.fetchContent
            resolve(content)
          case .failure(let error):
            DashXLog.d(tag: #function, "Encountered an error during fetchContent(): \(error)")
            reject("", error.localizedDescription, error)
          }
        }
    }

    func searchContent(
        _ contentType: String,
        _ returnType: String,
        _ filter: NSDictionary?,
        _ order: NSDictionary?,
        _ limit: Int?,
        _ preview: Bool? = true,
        _ language: String?,
        _ fields: [String]? = [],
        _ include: [String]? = [],
        _ exclude: [String]? = [],
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock
    ) {
        let searchContentsInput  = DashXGql.SearchContentInput(
            contentType: contentType,
            returnType: returnType,
            filter: filter as? [String: Any],
            order: order as? [String: Any],
            limit: limit,
            preview: preview,
            language: language,
            fields: fields,
            include: include,
            exclude: exclude
        )

        DashXLog.d(tag: #function, "Calling searchContent with \(searchContentsInput)")

        let searchContentQuery = DashXGql.SearchContentQuery(input: searchContentsInput)

        Network.shared.apollo.fetch(query: searchContentQuery, cachePolicy: .returnCacheDataElseFetch) { result in
          switch result {
          case .success(let graphQLResult):
            let json = graphQLResult.data?.searchContent
            DashXLog.d(tag: #function, "Sent searchContents with \(String(describing: json))")
            resolve(json)
          case .failure(let error):
            DashXLog.d(tag: #function, "Encountered an error during searchContent(): \(error)")
            reject("", error.localizedDescription, error)
          }
        }
    }
    // MARK: -- cart

    func addItemToCart(
        _ itemId: String,
        _ pricingId: String,
        _ quantity: String,
        _ reset: Bool,
        _ custom: NSDictionary?,
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock
    ) {
        let addItemToCartInput  = DashXGql.AddItemToCartInput(
             accountUid: self.uid, accountAnonymousUid: self.anonymousUid, itemId: itemId, pricingId: pricingId, quantity: quantity, reset: reset, custom: custom as? [String: JSONDecodable?]
        )

        DashXLog.d(tag: #function, "Calling addItemToCart with \(addItemToCartInput)")

        let addItemToCartMutation = DashXGql.AddItemToCartMutation(input: addItemToCartInput)

        Network.shared.apollo.perform(mutation: addItemToCartMutation) { result in
          switch result {
          case .success(let graphQLResult):
            let json = graphQLResult.data?.addItemToCart
            DashXLog.d(tag: #function, "Sent addItemToCart with \(String(describing: json))")
            resolve(json?.resultMap)
          case .failure(let error):
            DashXLog.d(tag: #function, "Encountered an error during addItemToCart(): \(error)")
            reject("", error.localizedDescription, error)
          }
        }
    }

    func fetchCart(
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock
    ) {
        let fetchCartInput  = DashXGql.FetchCartInput(
            accountUid: self.uid, accountAnonymousUid: self.anonymousUid
        )

        DashXLog.d(tag: #function, "Calling fetchCart with \(fetchCartInput)")

        let fetchCartQuery = DashXGql.FetchCartQuery(input: fetchCartInput)

        Network.shared.apollo.fetch(query: fetchCartQuery) { result in
          switch result {
          case .success(let graphQLResult):
            let json = graphQLResult.data?.fetchCart
            DashXLog.d(tag: #function, "Sent fetchCart with \(String(describing: json))")
            resolve(json?.resultMap)
          case .failure(let error):
            DashXLog.d(tag: #function, "Encountered an error during fetchCart(): \(error)")
            reject("", error.localizedDescription, error)
          }
        }
    }
}
