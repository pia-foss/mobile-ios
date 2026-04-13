import Foundation
import PIADashboard
import PIALibrary
import PIALocalizations

// Extension to add isExpired convenience property
extension AccountProvider {
    var isExpired: Bool {
        currentUser?.info?.isExpired ?? false
    }
}

extension Server: @retroactive ServerType {
    public var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }

    public var dipStatusString: String? {
        dipStatus?.getStatus()
    }

    public var dipIKEv2IP: String? {
        iKEv2AddressesForUDP?.first?.ip
    }
}

extension SelectedServerUseCase {
    public static func automaticServer() -> ServerType {
        Server(
            serial: "",
            name: L10n.Global.automatic,
            country: "universal",
            hostname: "auto.bogus.domain",
            pingAddress: nil,
            regionIdentifier: "auto"
        )
    }
}

extension DedicatedIPStatus: @retroactive DedicatedIPStatusType {
    public func getStatus() -> String {
        switch self {
        case .invalid:
            return L10n.Settings.Dedicatedip.Status.invalid
        case .expired:
            return L10n.Settings.Dedicatedip.Status.expired
        case .error:
            return L10n.Settings.Dedicatedip.Status.error
        default:
            return L10n.Settings.Dedicatedip.Status.active
        }
    }
}

extension DefaultServerProvider: @retroactive ServerProviderType {
    public var historicalServersType: [ServerType] {
        return self.historicalServers
    }

    public var targetServerType: ServerType {
        get throws {
            try self.targetServer
        }
    }

    public var currentServersType: [ServerType] {
        return self.currentServers
    }
}
