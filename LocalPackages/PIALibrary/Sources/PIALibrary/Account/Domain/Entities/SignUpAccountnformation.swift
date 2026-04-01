
import Foundation

struct SignUpAccountnformation: Codable {
    let status: String
    let username: String
    let password: String
}

extension SignUpAccountnformation {
    func toDomainModel() -> Credentials {
        Credentials(username: username, password: password)
    }
    
    static func makeWith(data: Data) -> SignUpAccountnformation? {
        try? JSONDecoder().decode(SignUpAccountnformation.self, from: data)
    }
}
