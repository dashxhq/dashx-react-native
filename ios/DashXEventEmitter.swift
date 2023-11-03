class DashXEventEmitter {
    static let instance = DashXEventEmitter()
    private static var eventEmitter: DashXReactNative!

    private init() {}

    func registerEventEmitter(eventEmitter: DashXReactNative) {
        DashXEventEmitter.eventEmitter = eventEmitter
    }

    func dispatch(name: String, body: Any?) {
        DashXEventEmitter.eventEmitter.sendEvent(withName: name, body: body)
    }
}
