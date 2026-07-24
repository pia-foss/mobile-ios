import Foundation
import PIABase

struct SignupInformation: Encodable {
    let store: String
    let receipt: JWS
    let email: String
    let marketing: String?
    let debug: String?
}

extension SignupInformation {
    func toData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
