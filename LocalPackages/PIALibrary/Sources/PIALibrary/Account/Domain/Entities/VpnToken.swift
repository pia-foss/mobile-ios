
import Foundation

public struct VpnToken: Codable {
    let vpnUsernameToken: String
    let vpnPasswordToken: String
    let expiresAt: Date
    
    enum CodingKeys: String, CodingKey {
        case vpnUsernameToken = "vpn_secret1"
        case vpnPasswordToken = "vpn_secret2"
        case expiresAt = "expires_at"
    }
    
    var isExpired: Bool {
        expiresAt.timeIntervalSinceNow.sign == .minus
    }
}

