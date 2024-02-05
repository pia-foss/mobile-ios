
import Foundation
import PIALibrary


protocol AccountProviderType {
    var isLoggedIn: Bool { get }
    func logout(_ callback: ((Error?) -> Void)?)
}

extension DefaultAccountProvider: AccountProviderType { }

protocol ServerType {
    var name: String { get }
    var identifier: String { get }
    var regionIdentifier: String { get }
    var country: String { get }
    var geo: Bool { get }
    var pingTime: Int? { get }
}

extension Server: ServerType {}

protocol ServerProviderType {
    var historicalServers: [Server] { get }
    var targetServer: Server { get }
    var currentServers: [Server] { get }
    
    // Add methods from ServerProvider to this protocol as needed
}

extension DefaultServerProvider: ServerProviderType {
}

protocol VPNStatusProviderType {
    var vpnStatus: VPNStatus { get }
}

extension DefaultVPNProvider: VPNStatusProviderType {}
