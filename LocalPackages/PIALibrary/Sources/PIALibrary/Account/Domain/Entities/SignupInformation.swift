
import Foundation

struct SignupInformation: Encodable {
    let store: String
    let receipt: String
    let email: String
    let marketing: String?
    let debug: String?
}

extension SignupInformation {
    func toData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
