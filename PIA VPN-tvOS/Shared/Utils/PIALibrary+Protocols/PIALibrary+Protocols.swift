
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
    var isAutomatic: Bool { get }
}

extension Server: ServerType {}

protocol ServerProviderType {
    var historicalServersType: [ServerType] { get }
    var targetServerType: ServerType { get }
    var currentServersType: [ServerType] { get }
    
    // Add methods from ServerProvider to this protocol as needed
}

extension DefaultServerProvider: ServerProviderType {
    var historicalServersType: [ServerType] {
        return self.historicalServers
    }
    
    var targetServerType: ServerType {
        return self.targetServer
    }
    
    var currentServersType: [ServerType] {
        return self.currentServers
    }
    
}

protocol VPNStatusProviderType {
    var vpnStatus: VPNStatus { get }
    func connect(_ callback: SuccessLibraryCallback?)
    func disconnect(_ callback: SuccessLibraryCallback?)
    
}

extension DefaultVPNProvider: VPNStatusProviderType {}
