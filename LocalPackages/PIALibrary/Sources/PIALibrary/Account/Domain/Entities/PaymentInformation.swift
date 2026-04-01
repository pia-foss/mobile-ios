
import Foundation

struct PaymentInformation: Encodable {
    let store: String
    let receipt: String
    let marketing: String?
    let debug: String?
}

extension PaymentInformation {
    func toData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
