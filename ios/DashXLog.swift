import Foundation
import os.log

class DashXLog {
    enum LogLevel: Int {
        case info = 1
        case debug = 0
        case off = -1

        static func <= (lhs: Self, rhs: Self) -> Bool {
            return lhs.rawValue <= rhs.rawValue
        }

        func on () -> Bool {
            return self.rawValue > LogLevel.off.rawValue
        }
    }

    static private var logLevel: LogLevel = .off

    static func setLogLevel(to: Int) {
        self.logLevel = LogLevel(rawValue: to) ?? .off
    }

    static func d(tag: String, _ data: String) {
        if logLevel.on() && logLevel <= .debug {
            if #available(iOS 10.0, *) {
                os_log("%@: %@", type: .debug, tag, data)
            } else {
                print("%@: %@", tag, data)
            }
        }
    }

    static func i(tag: String, _ data: String) {
        if logLevel.on() && logLevel <= .info {
            if #available(iOS 10.0, *) {
                os_log("%@: %@", type: .info, tag, data)
            } else {
                print("%@: %@", tag, data)
            }
        }
    }
}
