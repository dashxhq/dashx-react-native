// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// DashXGql namespace
public enum DashXGql {
  public struct AddContentInput: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    /// - Parameters:
    ///   - contentType
    ///   - content
    ///   - data
    public init(contentType: String, content: Swift.Optional<String?> = nil, data: JSON) {
      graphQLMap = ["contentType": contentType, "content": content, "data": data]
    }

    public var contentType: String {
      get {
        return graphQLMap["contentType"] as! String
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "contentType")
      }
    }

    public var content: Swift.Optional<String?> {
      get {
        return graphQLMap["content"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "content")
      }
    }

    public var data: JSON {
      get {
        return graphQLMap["data"] as! JSON
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "data")
      }
    }
  }

  public struct AddItemToCartInput: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    /// - Parameters:
    ///   - accountUid
    ///   - accountAnonymousUid
    ///   - itemId
    ///   - pricingId
    ///   - quantity
    ///   - reset
    ///   - custom
    public init(accountUid: Swift.Optional<String?> = nil, accountAnonymousUid: Swift.Optional<String?> = nil, itemId: UUID, pricingId: UUID, quantity: Decimal, reset: Bool, custom: Swift.Optional<JSON?> = nil) {
      graphQLMap = ["accountUid": accountUid, "accountAnonymousUid": accountAnonymousUid, "itemId": itemId, "pricingId": pricingId, "quantity": quantity, "reset": reset, "custom": custom]
    }

    public var accountUid: Swift.Optional<String?> {
      get {
        return graphQLMap["accountUid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "accountUid")
      }
    }

    public var accountAnonymousUid: Swift.Optional<String?> {
      get {
        return graphQLMap["accountAnonymousUid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "accountAnonymousUid")
      }
    }

    public var itemId: UUID {
      get {
        return graphQLMap["itemId"] as! UUID
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "itemId")
      }
    }

    public var pricingId: UUID {
      get {
        return graphQLMap["pricingId"] as! UUID
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "pricingId")
      }
    }

    public var quantity: Decimal {
      get {
        return graphQLMap["quantity"] as! Decimal
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "quantity")
      }
    }

    public var reset: Bool {
      get {
        return graphQLMap["reset"] as! Bool
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "reset")
      }
    }

    public var custom: Swift.Optional<JSON?> {
      get {
        return graphQLMap["custom"] as? Swift.Optional<JSON?> ?? Swift.Optional<JSON?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "custom")
      }
    }
  }

  public enum OrderStatus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case draft
    case initial
    case checkedOut
    case paid
    case canceled
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "DRAFT": self = .draft
        case "INITIAL": self = .initial
        case "CHECKED_OUT": self = .checkedOut
        case "PAID": self = .paid
        case "CANCELED": self = .canceled
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .draft: return "DRAFT"
        case .initial: return "INITIAL"
        case .checkedOut: return "CHECKED_OUT"
        case .paid: return "PAID"
        case .canceled: return "CANCELED"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: OrderStatus, rhs: OrderStatus) -> Bool {
      switch (lhs, rhs) {
        case (.draft, .draft): return true
        case (.initial, .initial): return true
        case (.checkedOut, .checkedOut): return true
        case (.paid, .paid): return true
        case (.canceled, .canceled): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [OrderStatus] {
      return [
        .draft,
        .initial,
        .checkedOut,
        .paid,
        .canceled,
      ]
    }
  }

  public enum CouponDiscountType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case fixed
    case percentage
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "FIXED": self = .fixed
        case "PERCENTAGE": self = .percentage
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .fixed: return "FIXED"
        case .percentage: return "PERCENTAGE"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: CouponDiscountType, rhs: CouponDiscountType) -> Bool {
      switch (lhs, rhs) {
        case (.fixed, .fixed): return true
        case (.percentage, .percentage): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [CouponDiscountType] {
      return [
        .fixed,
        .percentage,
      ]
    }
  }

  public struct EditContentInput: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    /// - Parameters:
    ///   - contentType
    ///   - content
    ///   - data
    public init(contentType: String, content: String, data: JSON) {
      graphQLMap = ["contentType": contentType, "content": content, "data": data]
    }

    public var contentType: String {
      get {
        return graphQLMap["contentType"] as! String
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "contentType")
      }
    }

    public var content: String {
      get {
        return graphQLMap["content"] as! String
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "content")
      }
    }

    public var data: JSON {
      get {
        return graphQLMap["data"] as! JSON
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "data")
      }
    }
  }

  public struct FetchCartInput: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    /// - Parameters:
    ///   - accountUid
    ///   - accountAnonymousUid
    ///   - orderId
    public init(accountUid: Swift.Optional<String?> = nil, accountAnonymousUid: Swift.Optional<String?> = nil, orderId: Swift.Optional<UUID?> = nil) {
      graphQLMap = ["accountUid": accountUid, "accountAnonymousUid": accountAnonymousUid, "orderId": orderId]
    }

    public var accountUid: Swift.Optional<String?> {
      get {
        return graphQLMap["accountUid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "accountUid")
      }
    }

    public var accountAnonymousUid: Swift.Optional<String?> {
      get {
        return graphQLMap["accountAnonymousUid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "accountAnonymousUid")
      }
    }

    public var orderId: Swift.Optional<UUID?> {
      get {
        return graphQLMap["orderId"] as? Swift.Optional<UUID?> ?? Swift.Optional<UUID?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "orderId")
      }
    }
  }

  public struct FetchContentInput: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    /// - Parameters:
    ///   - contentId
    ///   - contentType
    ///   - content
    ///   - preview
    ///   - language
    ///   - fields
    ///   - include
    ///   - exclude
    public init(contentId: Swift.Optional<UUID?> = nil, contentType: Swift.Optional<String?> = nil, content: Swift.Optional<String?> = nil, preview: Swift.Optional<Bool?> = nil, language: Swift.Optional<String?> = nil, fields: Swift.Optional<[String]?> = nil, include: Swift.Optional<[String]?> = nil, exclude: Swift.Optional<[String]?> = nil) {
      graphQLMap = ["contentId": contentId, "contentType": contentType, "content": content, "preview": preview, "language": language, "fields": fields, "include": include, "exclude": exclude]
    }

    public var contentId: Swift.Optional<UUID?> {
      get {
        return graphQLMap["contentId"] as? Swift.Optional<UUID?> ?? Swift.Optional<UUID?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "contentId")
      }
    }

    public var contentType: Swift.Optional<String?> {
      get {
        return graphQLMap["contentType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "contentType")
      }
    }

    public var content: Swift.Optional<String?> {
      get {
        return graphQLMap["content"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "content")
      }
    }

    public var preview: Swift.Optional<Bool?> {
      get {
        return graphQLMap["preview"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "preview")
      }
    }

    public var language: Swift.Optional<String?> {
      get {
        return graphQLMap["language"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "language")
      }
    }

    public var fields: Swift.Optional<[String]?> {
      get {
        return graphQLMap["fields"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "fields")
      }
    }

    public var include: Swift.Optional<[String]?> {
      get {
        return graphQLMap["include"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "include")
      }
    }

    public var exclude: Swift.Optional<[String]?> {
      get {
        return graphQLMap["exclude"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "exclude")
      }
    }
  }

  public struct IdentifyAccountInput: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    /// - Parameters:
    ///   - uid
    ///   - anonymousUid
    ///   - email
    ///   - phone
    ///   - name
    ///   - firstName
    ///   - lastName
    ///   - scope
    public init(uid: Swift.Optional<String?> = nil, anonymousUid: Swift.Optional<String?> = nil, email: Swift.Optional<String?> = nil, phone: Swift.Optional<String?> = nil, name: Swift.Optional<String?> = nil, firstName: Swift.Optional<String?> = nil, lastName: Swift.Optional<String?> = nil, scope: Swift.Optional<String?> = nil) {
      graphQLMap = ["uid": uid, "anonymousUid": anonymousUid, "email": email, "phone": phone, "name": name, "firstName": firstName, "lastName": lastName, "scope": scope]
    }

    public var uid: Swift.Optional<String?> {
      get {
        return graphQLMap["uid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "uid")
      }
    }

    public var anonymousUid: Swift.Optional<String?> {
      get {
        return graphQLMap["anonymousUid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "anonymousUid")
      }
    }

    public var email: Swift.Optional<String?> {
      get {
        return graphQLMap["email"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "email")
      }
    }

    public var phone: Swift.Optional<String?> {
      get {
        return graphQLMap["phone"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "phone")
      }
    }

    public var name: Swift.Optional<String?> {
      get {
        return graphQLMap["name"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "name")
      }
    }

    public var firstName: Swift.Optional<String?> {
      get {
        return graphQLMap["firstName"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "firstName")
      }
    }

    public var lastName: Swift.Optional<String?> {
      get {
        return graphQLMap["lastName"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "lastName")
      }
    }

    public var scope: Swift.Optional<String?> {
      get {
        return graphQLMap["scope"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "scope")
      }
    }
  }

  public struct SearchContentInput: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    /// - Parameters:
    ///   - contentType
    ///   - returnType
    ///   - filter
    ///   - order
    ///   - limit
    ///   - preview
    ///   - language
    ///   - fields
    ///   - include
    ///   - exclude
    public init(contentType: String, returnType: String, filter: Swift.Optional<JSON?> = nil, order: Swift.Optional<JSON?> = nil, limit: Swift.Optional<Int?> = nil, preview: Swift.Optional<Bool?> = nil, language: Swift.Optional<String?> = nil, fields: Swift.Optional<[String]?> = nil, include: Swift.Optional<[String]?> = nil, exclude: Swift.Optional<[String]?> = nil) {
      graphQLMap = ["contentType": contentType, "returnType": returnType, "filter": filter, "order": order, "limit": limit, "preview": preview, "language": language, "fields": fields, "include": include, "exclude": exclude]
    }

    public var contentType: String {
      get {
        return graphQLMap["contentType"] as! String
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "contentType")
      }
    }

    public var returnType: String {
      get {
        return graphQLMap["returnType"] as! String
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "returnType")
      }
    }

    public var filter: Swift.Optional<JSON?> {
      get {
        return graphQLMap["filter"] as? Swift.Optional<JSON?> ?? Swift.Optional<JSON?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "filter")
      }
    }

    public var order: Swift.Optional<JSON?> {
      get {
        return graphQLMap["order"] as? Swift.Optional<JSON?> ?? Swift.Optional<JSON?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "order")
      }
    }

    public var limit: Swift.Optional<Int?> {
      get {
        return graphQLMap["limit"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "limit")
      }
    }

    public var preview: Swift.Optional<Bool?> {
      get {
        return graphQLMap["preview"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "preview")
      }
    }

    public var language: Swift.Optional<String?> {
      get {
        return graphQLMap["language"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "language")
      }
    }

    public var fields: Swift.Optional<[String]?> {
      get {
        return graphQLMap["fields"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "fields")
      }
    }

    public var include: Swift.Optional<[String]?> {
      get {
        return graphQLMap["include"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "include")
      }
    }

    public var exclude: Swift.Optional<[String]?> {
      get {
        return graphQLMap["exclude"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "exclude")
      }
    }
  }

  public struct SubscribeContactInput: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    /// - Parameters:
    ///   - accountUid
    ///   - accountAnonymousUid
    ///   - name
    ///   - kind
    ///   - value
    ///   - userAgent
    ///   - osName
    ///   - osVersion
    ///   - deviceModel
    ///   - deviceManufacturer
    ///   - deviceUid
    ///   - deviceAdvertisingUid
    ///   - isDeviceAdTrackingEnabled
    ///   - tag
    public init(accountUid: Swift.Optional<String?> = nil, accountAnonymousUid: Swift.Optional<String?> = nil, name: Swift.Optional<String?> = nil, kind: ContactKind, value: String, userAgent: Swift.Optional<String?> = nil, osName: Swift.Optional<String?> = nil, osVersion: Swift.Optional<String?> = nil, deviceModel: Swift.Optional<String?> = nil, deviceManufacturer: Swift.Optional<String?> = nil, deviceUid: Swift.Optional<String?> = nil, deviceAdvertisingUid: Swift.Optional<String?> = nil, isDeviceAdTrackingEnabled: Swift.Optional<Bool?> = nil, tag: Swift.Optional<String?> = nil) {
      graphQLMap = ["accountUid": accountUid, "accountAnonymousUid": accountAnonymousUid, "name": name, "kind": kind, "value": value, "userAgent": userAgent, "osName": osName, "osVersion": osVersion, "deviceModel": deviceModel, "deviceManufacturer": deviceManufacturer, "deviceUid": deviceUid, "deviceAdvertisingUid": deviceAdvertisingUid, "isDeviceAdTrackingEnabled": isDeviceAdTrackingEnabled, "tag": tag]
    }

    public var accountUid: Swift.Optional<String?> {
      get {
        return graphQLMap["accountUid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "accountUid")
      }
    }

    public var accountAnonymousUid: Swift.Optional<String?> {
      get {
        return graphQLMap["accountAnonymousUid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "accountAnonymousUid")
      }
    }

    public var name: Swift.Optional<String?> {
      get {
        return graphQLMap["name"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "name")
      }
    }

    public var kind: ContactKind {
      get {
        return graphQLMap["kind"] as! ContactKind
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "kind")
      }
    }

    public var value: String {
      get {
        return graphQLMap["value"] as! String
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "value")
      }
    }

    public var userAgent: Swift.Optional<String?> {
      get {
        return graphQLMap["userAgent"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "userAgent")
      }
    }

    public var osName: Swift.Optional<String?> {
      get {
        return graphQLMap["osName"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "osName")
      }
    }

    public var osVersion: Swift.Optional<String?> {
      get {
        return graphQLMap["osVersion"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "osVersion")
      }
    }

    public var deviceModel: Swift.Optional<String?> {
      get {
        return graphQLMap["deviceModel"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "deviceModel")
      }
    }

    public var deviceManufacturer: Swift.Optional<String?> {
      get {
        return graphQLMap["deviceManufacturer"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "deviceManufacturer")
      }
    }

    public var deviceUid: Swift.Optional<String?> {
      get {
        return graphQLMap["deviceUid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "deviceUid")
      }
    }

    public var deviceAdvertisingUid: Swift.Optional<String?> {
      get {
        return graphQLMap["deviceAdvertisingUid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "deviceAdvertisingUid")
      }
    }

    public var isDeviceAdTrackingEnabled: Swift.Optional<Bool?> {
      get {
        return graphQLMap["isDeviceAdTrackingEnabled"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "isDeviceAdTrackingEnabled")
      }
    }

    public var tag: Swift.Optional<String?> {
      get {
        return graphQLMap["tag"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "tag")
      }
    }
  }

  public enum ContactKind: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
    public typealias RawValue = String
    case email
    case phone
    case ios
    case android
    case web
    case whatsapp
    /// Auto generated constant for unknown enum values
    case __unknown(RawValue)

    public init?(rawValue: RawValue) {
      switch rawValue {
        case "EMAIL": self = .email
        case "PHONE": self = .phone
        case "IOS": self = .ios
        case "ANDROID": self = .android
        case "WEB": self = .web
        case "WHATSAPP": self = .whatsapp
        default: self = .__unknown(rawValue)
      }
    }

    public var rawValue: RawValue {
      switch self {
        case .email: return "EMAIL"
        case .phone: return "PHONE"
        case .ios: return "IOS"
        case .android: return "ANDROID"
        case .web: return "WEB"
        case .whatsapp: return "WHATSAPP"
        case .__unknown(let value): return value
      }
    }

    public static func == (lhs: ContactKind, rhs: ContactKind) -> Bool {
      switch (lhs, rhs) {
        case (.email, .email): return true
        case (.phone, .phone): return true
        case (.ios, .ios): return true
        case (.android, .android): return true
        case (.web, .web): return true
        case (.whatsapp, .whatsapp): return true
        case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
        default: return false
      }
    }

    public static var allCases: [ContactKind] {
      return [
        .email,
        .phone,
        .ios,
        .android,
        .web,
        .whatsapp,
      ]
    }
  }

  public struct TrackEventInput: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    /// - Parameters:
    ///   - event
    ///   - accountUid
    ///   - accountAnonymousUid
    ///   - data
    ///   - timestamp
    public init(event: String, accountUid: Swift.Optional<String?> = nil, accountAnonymousUid: Swift.Optional<String?> = nil, data: Swift.Optional<JSON?> = nil, timestamp: Swift.Optional<DateTime?> = nil) {
      graphQLMap = ["event": event, "accountUid": accountUid, "accountAnonymousUid": accountAnonymousUid, "data": data, "timestamp": timestamp]
    }

    public var event: String {
      get {
        return graphQLMap["event"] as! String
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "event")
      }
    }

    public var accountUid: Swift.Optional<String?> {
      get {
        return graphQLMap["accountUid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "accountUid")
      }
    }

    public var accountAnonymousUid: Swift.Optional<String?> {
      get {
        return graphQLMap["accountAnonymousUid"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "accountAnonymousUid")
      }
    }

    public var data: Swift.Optional<JSON?> {
      get {
        return graphQLMap["data"] as? Swift.Optional<JSON?> ?? Swift.Optional<JSON?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "data")
      }
    }

    public var timestamp: Swift.Optional<DateTime?> {
      get {
        return graphQLMap["timestamp"] as? Swift.Optional<DateTime?> ?? Swift.Optional<DateTime?>.none
      }
      set {
        graphQLMap.updateValue(newValue, forKey: "timestamp")
      }
    }
  }

  public final class AddContentMutation: GraphQLMutation {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      mutation AddContent($input: AddContentInput!) {
        addContent(input: $input) {
          __typename
          id
          position
          identifier
          data
        }
      }
      """

    public let operationName: String = "AddContent"

    public var input: AddContentInput

    public init(input: AddContentInput) {
      self.input = input
    }

    public var variables: GraphQLMap? {
      return ["input": input]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Mutation"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("addContent", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(AddContent.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(addContent: AddContent) {
        self.init(unsafeResultMap: ["__typename": "Mutation", "addContent": addContent.resultMap])
      }

      public var addContent: AddContent {
        get {
          return AddContent(unsafeResultMap: resultMap["addContent"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "addContent")
        }
      }

      public struct AddContent: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["CustomContent"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(UUID.self))),
            GraphQLField("position", type: .nonNull(.scalar(Int.self))),
            GraphQLField("identifier", type: .nonNull(.scalar(String.self))),
            GraphQLField("data", type: .nonNull(.scalar(JSON.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: UUID, position: Int, identifier: String, data: JSON) {
          self.init(unsafeResultMap: ["__typename": "CustomContent", "id": id, "position": position, "identifier": identifier, "data": data])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: UUID {
          get {
            return resultMap["id"]! as! UUID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var position: Int {
          get {
            return resultMap["position"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "position")
          }
        }

        public var identifier: String {
          get {
            return resultMap["identifier"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "identifier")
          }
        }

        public var data: JSON {
          get {
            return resultMap["data"]! as! JSON
          }
          set {
            resultMap.updateValue(newValue, forKey: "data")
          }
        }
      }
    }
  }

  public final class AddItemToCartMutation: GraphQLMutation {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      mutation AddItemToCart($input: AddItemToCartInput!) {
        addItemToCart(input: $input) {
          __typename
          id
          status
          subtotal
          discount
          tax
          total
          gatewayMeta
          currencyCode
          orderItems {
            __typename
            id
            quantity
            unitPrice
            subtotal
            discount
            tax
            total
            custom
            currencyCode
          }
          couponRedemptions {
            __typename
            coupon {
              __typename
              name
              identifier
              discountType
              discountAmount
              currencyCode
              expiresAt
            }
          }
        }
      }
      """

    public let operationName: String = "AddItemToCart"

    public var input: AddItemToCartInput

    public init(input: AddItemToCartInput) {
      self.input = input
    }

    public var variables: GraphQLMap? {
      return ["input": input]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Mutation"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("addItemToCart", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(AddItemToCart.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(addItemToCart: AddItemToCart) {
        self.init(unsafeResultMap: ["__typename": "Mutation", "addItemToCart": addItemToCart.resultMap])
      }

      public var addItemToCart: AddItemToCart {
        get {
          return AddItemToCart(unsafeResultMap: resultMap["addItemToCart"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "addItemToCart")
        }
      }

      public struct AddItemToCart: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Order"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(UUID.self))),
            GraphQLField("status", type: .nonNull(.scalar(OrderStatus.self))),
            GraphQLField("subtotal", type: .nonNull(.scalar(Decimal.self))),
            GraphQLField("discount", type: .nonNull(.scalar(Decimal.self))),
            GraphQLField("tax", type: .nonNull(.scalar(Decimal.self))),
            GraphQLField("total", type: .nonNull(.scalar(Decimal.self))),
            GraphQLField("gatewayMeta", type: .scalar(JSON.self)),
            GraphQLField("currencyCode", type: .nonNull(.scalar(String.self))),
            GraphQLField("orderItems", type: .nonNull(.list(.nonNull(.object(OrderItem.selections))))),
            GraphQLField("couponRedemptions", type: .nonNull(.list(.nonNull(.object(CouponRedemption.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: UUID, status: OrderStatus, subtotal: Decimal, discount: Decimal, tax: Decimal, total: Decimal, gatewayMeta: JSON? = nil, currencyCode: String, orderItems: [OrderItem], couponRedemptions: [CouponRedemption]) {
          self.init(unsafeResultMap: ["__typename": "Order", "id": id, "status": status, "subtotal": subtotal, "discount": discount, "tax": tax, "total": total, "gatewayMeta": gatewayMeta, "currencyCode": currencyCode, "orderItems": orderItems.map { (value: OrderItem) -> ResultMap in value.resultMap }, "couponRedemptions": couponRedemptions.map { (value: CouponRedemption) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: UUID {
          get {
            return resultMap["id"]! as! UUID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var status: OrderStatus {
          get {
            return resultMap["status"]! as! OrderStatus
          }
          set {
            resultMap.updateValue(newValue, forKey: "status")
          }
        }

        public var subtotal: Decimal {
          get {
            return resultMap["subtotal"]! as! Decimal
          }
          set {
            resultMap.updateValue(newValue, forKey: "subtotal")
          }
        }

        public var discount: Decimal {
          get {
            return resultMap["discount"]! as! Decimal
          }
          set {
            resultMap.updateValue(newValue, forKey: "discount")
          }
        }

        public var tax: Decimal {
          get {
            return resultMap["tax"]! as! Decimal
          }
          set {
            resultMap.updateValue(newValue, forKey: "tax")
          }
        }

        public var total: Decimal {
          get {
            return resultMap["total"]! as! Decimal
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }

        public var gatewayMeta: JSON? {
          get {
            return resultMap["gatewayMeta"] as? JSON
          }
          set {
            resultMap.updateValue(newValue, forKey: "gatewayMeta")
          }
        }

        public var currencyCode: String {
          get {
            return resultMap["currencyCode"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currencyCode")
          }
        }

        public var orderItems: [OrderItem] {
          get {
            return (resultMap["orderItems"] as! [ResultMap]).map { (value: ResultMap) -> OrderItem in OrderItem(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: OrderItem) -> ResultMap in value.resultMap }, forKey: "orderItems")
          }
        }

        public var couponRedemptions: [CouponRedemption] {
          get {
            return (resultMap["couponRedemptions"] as! [ResultMap]).map { (value: ResultMap) -> CouponRedemption in CouponRedemption(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: CouponRedemption) -> ResultMap in value.resultMap }, forKey: "couponRedemptions")
          }
        }

        public struct OrderItem: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["OrderItem"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .nonNull(.scalar(UUID.self))),
              GraphQLField("quantity", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("unitPrice", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("subtotal", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("discount", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("tax", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("total", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("custom", type: .nonNull(.scalar(JSON.self))),
              GraphQLField("currencyCode", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: UUID, quantity: Decimal, unitPrice: Decimal, subtotal: Decimal, discount: Decimal, tax: Decimal, total: Decimal, custom: JSON, currencyCode: String) {
            self.init(unsafeResultMap: ["__typename": "OrderItem", "id": id, "quantity": quantity, "unitPrice": unitPrice, "subtotal": subtotal, "discount": discount, "tax": tax, "total": total, "custom": custom, "currencyCode": currencyCode])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: UUID {
            get {
              return resultMap["id"]! as! UUID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var quantity: Decimal {
            get {
              return resultMap["quantity"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "quantity")
            }
          }

          public var unitPrice: Decimal {
            get {
              return resultMap["unitPrice"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "unitPrice")
            }
          }

          public var subtotal: Decimal {
            get {
              return resultMap["subtotal"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "subtotal")
            }
          }

          public var discount: Decimal {
            get {
              return resultMap["discount"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "discount")
            }
          }

          public var tax: Decimal {
            get {
              return resultMap["tax"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "tax")
            }
          }

          public var total: Decimal {
            get {
              return resultMap["total"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "total")
            }
          }

          public var custom: JSON {
            get {
              return resultMap["custom"]! as! JSON
            }
            set {
              resultMap.updateValue(newValue, forKey: "custom")
            }
          }

          public var currencyCode: String {
            get {
              return resultMap["currencyCode"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currencyCode")
            }
          }
        }

        public struct CouponRedemption: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["CouponRedemption"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("coupon", type: .nonNull(.object(Coupon.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(coupon: Coupon) {
            self.init(unsafeResultMap: ["__typename": "CouponRedemption", "coupon": coupon.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var coupon: Coupon {
            get {
              return Coupon(unsafeResultMap: resultMap["coupon"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "coupon")
            }
          }

          public struct Coupon: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Coupon"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("name", type: .nonNull(.scalar(String.self))),
                GraphQLField("identifier", type: .nonNull(.scalar(String.self))),
                GraphQLField("discountType", type: .nonNull(.scalar(CouponDiscountType.self))),
                GraphQLField("discountAmount", type: .nonNull(.scalar(Decimal.self))),
                GraphQLField("currencyCode", type: .scalar(String.self)),
                GraphQLField("expiresAt", type: .scalar(DateTime.self)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(name: String, identifier: String, discountType: CouponDiscountType, discountAmount: Decimal, currencyCode: String? = nil, expiresAt: DateTime? = nil) {
              self.init(unsafeResultMap: ["__typename": "Coupon", "name": name, "identifier": identifier, "discountType": discountType, "discountAmount": discountAmount, "currencyCode": currencyCode, "expiresAt": expiresAt])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var name: String {
              get {
                return resultMap["name"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "name")
              }
            }

            public var identifier: String {
              get {
                return resultMap["identifier"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "identifier")
              }
            }

            public var discountType: CouponDiscountType {
              get {
                return resultMap["discountType"]! as! CouponDiscountType
              }
              set {
                resultMap.updateValue(newValue, forKey: "discountType")
              }
            }

            public var discountAmount: Decimal {
              get {
                return resultMap["discountAmount"]! as! Decimal
              }
              set {
                resultMap.updateValue(newValue, forKey: "discountAmount")
              }
            }

            public var currencyCode: String? {
              get {
                return resultMap["currencyCode"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "currencyCode")
              }
            }

            public var expiresAt: DateTime? {
              get {
                return resultMap["expiresAt"] as? DateTime
              }
              set {
                resultMap.updateValue(newValue, forKey: "expiresAt")
              }
            }
          }
        }
      }
    }
  }

  public final class EditContentMutation: GraphQLMutation {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      mutation EditContent($input: EditContentInput!) {
        editContent(input: $input) {
          __typename
          id
          position
          identifier
          data
        }
      }
      """

    public let operationName: String = "EditContent"

    public var input: EditContentInput

    public init(input: EditContentInput) {
      self.input = input
    }

    public var variables: GraphQLMap? {
      return ["input": input]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Mutation"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("editContent", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(EditContent.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(editContent: EditContent) {
        self.init(unsafeResultMap: ["__typename": "Mutation", "editContent": editContent.resultMap])
      }

      public var editContent: EditContent {
        get {
          return EditContent(unsafeResultMap: resultMap["editContent"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "editContent")
        }
      }

      public struct EditContent: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["CustomContent"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(UUID.self))),
            GraphQLField("position", type: .nonNull(.scalar(Int.self))),
            GraphQLField("identifier", type: .nonNull(.scalar(String.self))),
            GraphQLField("data", type: .nonNull(.scalar(JSON.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: UUID, position: Int, identifier: String, data: JSON) {
          self.init(unsafeResultMap: ["__typename": "CustomContent", "id": id, "position": position, "identifier": identifier, "data": data])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: UUID {
          get {
            return resultMap["id"]! as! UUID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var position: Int {
          get {
            return resultMap["position"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "position")
          }
        }

        public var identifier: String {
          get {
            return resultMap["identifier"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "identifier")
          }
        }

        public var data: JSON {
          get {
            return resultMap["data"]! as! JSON
          }
          set {
            resultMap.updateValue(newValue, forKey: "data")
          }
        }
      }
    }
  }

  public final class FetchCartQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query FetchCart($input: FetchCartInput!) {
        fetchCart(input: $input) {
          __typename
          id
          status
          subtotal
          discount
          tax
          total
          gatewayMeta
          currencyCode
          orderItems {
            __typename
            id
            quantity
            unitPrice
            subtotal
            discount
            tax
            total
            custom
            currencyCode
          }
          couponRedemptions {
            __typename
            coupon {
              __typename
              name
              identifier
              discountType
              discountAmount
              currencyCode
              expiresAt
            }
          }
        }
      }
      """

    public let operationName: String = "FetchCart"

    public var input: FetchCartInput

    public init(input: FetchCartInput) {
      self.input = input
    }

    public var variables: GraphQLMap? {
      return ["input": input]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("fetchCart", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(FetchCart.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(fetchCart: FetchCart) {
        self.init(unsafeResultMap: ["__typename": "Query", "fetchCart": fetchCart.resultMap])
      }

      public var fetchCart: FetchCart {
        get {
          return FetchCart(unsafeResultMap: resultMap["fetchCart"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "fetchCart")
        }
      }

      public struct FetchCart: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Order"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(UUID.self))),
            GraphQLField("status", type: .nonNull(.scalar(OrderStatus.self))),
            GraphQLField("subtotal", type: .nonNull(.scalar(Decimal.self))),
            GraphQLField("discount", type: .nonNull(.scalar(Decimal.self))),
            GraphQLField("tax", type: .nonNull(.scalar(Decimal.self))),
            GraphQLField("total", type: .nonNull(.scalar(Decimal.self))),
            GraphQLField("gatewayMeta", type: .scalar(JSON.self)),
            GraphQLField("currencyCode", type: .nonNull(.scalar(String.self))),
            GraphQLField("orderItems", type: .nonNull(.list(.nonNull(.object(OrderItem.selections))))),
            GraphQLField("couponRedemptions", type: .nonNull(.list(.nonNull(.object(CouponRedemption.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: UUID, status: OrderStatus, subtotal: Decimal, discount: Decimal, tax: Decimal, total: Decimal, gatewayMeta: JSON? = nil, currencyCode: String, orderItems: [OrderItem], couponRedemptions: [CouponRedemption]) {
          self.init(unsafeResultMap: ["__typename": "Order", "id": id, "status": status, "subtotal": subtotal, "discount": discount, "tax": tax, "total": total, "gatewayMeta": gatewayMeta, "currencyCode": currencyCode, "orderItems": orderItems.map { (value: OrderItem) -> ResultMap in value.resultMap }, "couponRedemptions": couponRedemptions.map { (value: CouponRedemption) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: UUID {
          get {
            return resultMap["id"]! as! UUID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var status: OrderStatus {
          get {
            return resultMap["status"]! as! OrderStatus
          }
          set {
            resultMap.updateValue(newValue, forKey: "status")
          }
        }

        public var subtotal: Decimal {
          get {
            return resultMap["subtotal"]! as! Decimal
          }
          set {
            resultMap.updateValue(newValue, forKey: "subtotal")
          }
        }

        public var discount: Decimal {
          get {
            return resultMap["discount"]! as! Decimal
          }
          set {
            resultMap.updateValue(newValue, forKey: "discount")
          }
        }

        public var tax: Decimal {
          get {
            return resultMap["tax"]! as! Decimal
          }
          set {
            resultMap.updateValue(newValue, forKey: "tax")
          }
        }

        public var total: Decimal {
          get {
            return resultMap["total"]! as! Decimal
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }

        public var gatewayMeta: JSON? {
          get {
            return resultMap["gatewayMeta"] as? JSON
          }
          set {
            resultMap.updateValue(newValue, forKey: "gatewayMeta")
          }
        }

        public var currencyCode: String {
          get {
            return resultMap["currencyCode"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "currencyCode")
          }
        }

        public var orderItems: [OrderItem] {
          get {
            return (resultMap["orderItems"] as! [ResultMap]).map { (value: ResultMap) -> OrderItem in OrderItem(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: OrderItem) -> ResultMap in value.resultMap }, forKey: "orderItems")
          }
        }

        public var couponRedemptions: [CouponRedemption] {
          get {
            return (resultMap["couponRedemptions"] as! [ResultMap]).map { (value: ResultMap) -> CouponRedemption in CouponRedemption(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: CouponRedemption) -> ResultMap in value.resultMap }, forKey: "couponRedemptions")
          }
        }

        public struct OrderItem: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["OrderItem"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .nonNull(.scalar(UUID.self))),
              GraphQLField("quantity", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("unitPrice", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("subtotal", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("discount", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("tax", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("total", type: .nonNull(.scalar(Decimal.self))),
              GraphQLField("custom", type: .nonNull(.scalar(JSON.self))),
              GraphQLField("currencyCode", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: UUID, quantity: Decimal, unitPrice: Decimal, subtotal: Decimal, discount: Decimal, tax: Decimal, total: Decimal, custom: JSON, currencyCode: String) {
            self.init(unsafeResultMap: ["__typename": "OrderItem", "id": id, "quantity": quantity, "unitPrice": unitPrice, "subtotal": subtotal, "discount": discount, "tax": tax, "total": total, "custom": custom, "currencyCode": currencyCode])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: UUID {
            get {
              return resultMap["id"]! as! UUID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var quantity: Decimal {
            get {
              return resultMap["quantity"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "quantity")
            }
          }

          public var unitPrice: Decimal {
            get {
              return resultMap["unitPrice"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "unitPrice")
            }
          }

          public var subtotal: Decimal {
            get {
              return resultMap["subtotal"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "subtotal")
            }
          }

          public var discount: Decimal {
            get {
              return resultMap["discount"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "discount")
            }
          }

          public var tax: Decimal {
            get {
              return resultMap["tax"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "tax")
            }
          }

          public var total: Decimal {
            get {
              return resultMap["total"]! as! Decimal
            }
            set {
              resultMap.updateValue(newValue, forKey: "total")
            }
          }

          public var custom: JSON {
            get {
              return resultMap["custom"]! as! JSON
            }
            set {
              resultMap.updateValue(newValue, forKey: "custom")
            }
          }

          public var currencyCode: String {
            get {
              return resultMap["currencyCode"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "currencyCode")
            }
          }
        }

        public struct CouponRedemption: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["CouponRedemption"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("coupon", type: .nonNull(.object(Coupon.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(coupon: Coupon) {
            self.init(unsafeResultMap: ["__typename": "CouponRedemption", "coupon": coupon.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var coupon: Coupon {
            get {
              return Coupon(unsafeResultMap: resultMap["coupon"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "coupon")
            }
          }

          public struct Coupon: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Coupon"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("name", type: .nonNull(.scalar(String.self))),
                GraphQLField("identifier", type: .nonNull(.scalar(String.self))),
                GraphQLField("discountType", type: .nonNull(.scalar(CouponDiscountType.self))),
                GraphQLField("discountAmount", type: .nonNull(.scalar(Decimal.self))),
                GraphQLField("currencyCode", type: .scalar(String.self)),
                GraphQLField("expiresAt", type: .scalar(DateTime.self)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(name: String, identifier: String, discountType: CouponDiscountType, discountAmount: Decimal, currencyCode: String? = nil, expiresAt: DateTime? = nil) {
              self.init(unsafeResultMap: ["__typename": "Coupon", "name": name, "identifier": identifier, "discountType": discountType, "discountAmount": discountAmount, "currencyCode": currencyCode, "expiresAt": expiresAt])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var name: String {
              get {
                return resultMap["name"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "name")
              }
            }

            public var identifier: String {
              get {
                return resultMap["identifier"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "identifier")
              }
            }

            public var discountType: CouponDiscountType {
              get {
                return resultMap["discountType"]! as! CouponDiscountType
              }
              set {
                resultMap.updateValue(newValue, forKey: "discountType")
              }
            }

            public var discountAmount: Decimal {
              get {
                return resultMap["discountAmount"]! as! Decimal
              }
              set {
                resultMap.updateValue(newValue, forKey: "discountAmount")
              }
            }

            public var currencyCode: String? {
              get {
                return resultMap["currencyCode"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "currencyCode")
              }
            }

            public var expiresAt: DateTime? {
              get {
                return resultMap["expiresAt"] as? DateTime
              }
              set {
                resultMap.updateValue(newValue, forKey: "expiresAt")
              }
            }
          }
        }
      }
    }
  }

  public final class FetchContentQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query FetchContent($input: FetchContentInput!) {
        fetchContent(input: $input)
      }
      """

    public let operationName: String = "FetchContent"

    public var input: FetchContentInput

    public init(input: FetchContentInput) {
      self.input = input
    }

    public var variables: GraphQLMap? {
      return ["input": input]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("fetchContent", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(JSON.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(fetchContent: JSON) {
        self.init(unsafeResultMap: ["__typename": "Query", "fetchContent": fetchContent])
      }

      public var fetchContent: JSON {
        get {
          return resultMap["fetchContent"]! as! JSON
        }
        set {
          resultMap.updateValue(newValue, forKey: "fetchContent")
        }
      }
    }
  }

  public final class IdentifyAccountMutation: GraphQLMutation {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      mutation IdentifyAccount($input: IdentifyAccountInput!) {
        identifyAccount(input: $input) {
          __typename
          id
        }
      }
      """

    public let operationName: String = "IdentifyAccount"

    public var input: IdentifyAccountInput

    public init(input: IdentifyAccountInput) {
      self.input = input
    }

    public var variables: GraphQLMap? {
      return ["input": input]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Mutation"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("identifyAccount", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(IdentifyAccount.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(identifyAccount: IdentifyAccount) {
        self.init(unsafeResultMap: ["__typename": "Mutation", "identifyAccount": identifyAccount.resultMap])
      }

      public var identifyAccount: IdentifyAccount {
        get {
          return IdentifyAccount(unsafeResultMap: resultMap["identifyAccount"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "identifyAccount")
        }
      }

      public struct IdentifyAccount: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Account"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(UUID.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: UUID) {
          self.init(unsafeResultMap: ["__typename": "Account", "id": id])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: UUID {
          get {
            return resultMap["id"]! as! UUID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }
      }
    }
  }

  public final class SearchContentQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query SearchContent($input: SearchContentInput!) {
        searchContent(input: $input)
      }
      """

    public let operationName: String = "SearchContent"

    public var input: SearchContentInput

    public init(input: SearchContentInput) {
      self.input = input
    }

    public var variables: GraphQLMap? {
      return ["input": input]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("searchContent", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.list(.nonNull(.scalar(JSON.self))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(searchContent: [JSON]) {
        self.init(unsafeResultMap: ["__typename": "Query", "searchContent": searchContent])
      }

      public var searchContent: [JSON] {
        get {
          return resultMap["searchContent"]! as! [JSON]
        }
        set {
          resultMap.updateValue(newValue, forKey: "searchContent")
        }
      }
    }
  }

  public final class SubscribeContactMutation: GraphQLMutation {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      mutation SubscribeContact($input: SubscribeContactInput!) {
        subscribeContact(input: $input) {
          __typename
          id
          value
        }
      }
      """

    public let operationName: String = "SubscribeContact"

    public var input: SubscribeContactInput

    public init(input: SubscribeContactInput) {
      self.input = input
    }

    public var variables: GraphQLMap? {
      return ["input": input]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Mutation"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("subscribeContact", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SubscribeContact.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(subscribeContact: SubscribeContact) {
        self.init(unsafeResultMap: ["__typename": "Mutation", "subscribeContact": subscribeContact.resultMap])
      }

      public var subscribeContact: SubscribeContact {
        get {
          return SubscribeContact(unsafeResultMap: resultMap["subscribeContact"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "subscribeContact")
        }
      }

      public struct SubscribeContact: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Contact"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(UUID.self))),
            GraphQLField("value", type: .nonNull(.scalar(String.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: UUID, value: String) {
          self.init(unsafeResultMap: ["__typename": "Contact", "id": id, "value": value])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: UUID {
          get {
            return resultMap["id"]! as! UUID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var value: String {
          get {
            return resultMap["value"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }

  public final class TrackEventMutation: GraphQLMutation {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      mutation TrackEvent($input: TrackEventInput!) {
        trackEvent(input: $input) {
          __typename
          success
        }
      }
      """

    public let operationName: String = "TrackEvent"

    public var input: TrackEventInput

    public init(input: TrackEventInput) {
      self.input = input
    }

    public var variables: GraphQLMap? {
      return ["input": input]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Mutation"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("trackEvent", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(TrackEvent.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(trackEvent: TrackEvent) {
        self.init(unsafeResultMap: ["__typename": "Mutation", "trackEvent": trackEvent.resultMap])
      }

      public var trackEvent: TrackEvent {
        get {
          return TrackEvent(unsafeResultMap: resultMap["trackEvent"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "trackEvent")
        }
      }

      public struct TrackEvent: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["TrackEventResponse"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(success: Bool) {
          self.init(unsafeResultMap: ["__typename": "TrackEventResponse", "success": success])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var success: Bool {
          get {
            return resultMap["success"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "success")
          }
        }
      }
    }
  }
}
