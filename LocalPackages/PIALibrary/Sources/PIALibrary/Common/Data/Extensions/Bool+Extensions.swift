
import Foundation

extension Bool {
    func toString() -> String {
        switch self {
        case true:
            return "true"
        case false:
            return "false"
        }
    }
}

