import Foundation

class DashXEventEmitter {
    static let instance = DashXEventEmitter()
    private static var eventEmitter: RCTEventEmitter!

    private init() {}

    func registerEventEmitter(eventEmitter: RCTEventEmitter) {
        DashXEventEmitter.eventEmitter = eventEmitter
    }

    func dispatch(name: String, body: Any?) {
        DashXEventEmitter.eventEmitter.sendEvent(withName: name, body: body)
    }
}
