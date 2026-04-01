
import Foundation


public struct APIToken: Codable {
    let apiToken: String
    let expiresAt: Date
    
    enum CodingKeys: String, CodingKey {
        case apiToken = "api_token"
        case expiresAt = "expires_at"
    }
    
    var isExpired: Bool {
        expiresAt.timeIntervalSinceNow.sign == .minus
    }
}


