import Foundation
import KapeVPN_PacketTunnel

extension IpAddress {
    init(parsing address: String) {
        self = address.contains(":") ? .v6(ipV6: address) : .v4(ipV4: address)
    }

    var hostLiteral: String {
        switch self {
        case .v4(ipV4: let ip): ip
        case .v6(ipV6: let ip): "[\(ip)]"
        }
    }
}
