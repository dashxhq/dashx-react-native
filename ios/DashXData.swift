import Foundation
import Apollo

public extension DashXGql {
    typealias JSON = [String : Any?]
    typealias Json = [String : Any?]
    typealias UUID = String
    typealias DateTime = String
    typealias Decimal = String
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
}
