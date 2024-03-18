
import Foundation
import PIALibrary


protocol AccountProviderType {
    var isLoggedIn: Bool { get }
    var publicUsername: String? { get }
    var currentUser: PIALibrary.UserAccount? { get set }
    func logout(_ callback: ((Error?) -> Void)?)
    func login(with linkToken: String, _ callback: ((PIALibrary.UserAccount?, Error?) -> Void)?)
}

extension DefaultAccountProvider: AccountProviderType { }

protocol ServerType {
    var id: ObjectIdentifier { get }
    var name: String { get }
    var identifier: String { get }
    var regionIdentifier: String { get }
    var country: String { get }
    var geo: Bool { get }
    var pingTime: Int? { get }
    var isAutomatic: Bool { get }
    var dipToken: String? { get }
    var dipIKEv2IP: String? { get }
    var dipStatusString: String? { get }
}

extension Server: ServerType {
    
    public var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
    
    var dipStatusString: String? {
        dipStatus?.getStatus()
    }
    
    var dipIKEv2IP: String? {
        iKEv2AddressesForUDP?.first?.ip
    }
}
protocol DedicatedIPStatusType {
    func getStatus() -> String
}

extension DedicatedIPStatus: DedicatedIPStatusType {
    func getStatus() -> String {
        switch self {
            case .invalid:
                return L10n.Localizable.Settings.Dedicatedip.Status.invalid
            case .expired:
                return L10n.Localizable.Settings.Dedicatedip.Status.expired
            case .error:
                return L10n.Localizable.Settings.Dedicatedip.Status.error
            default:
                return L10n.Localizable.Settings.Dedicatedip.Status.active
        }
    }
}


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

extension MockVPNProvider: VPNStatusProviderType {}
