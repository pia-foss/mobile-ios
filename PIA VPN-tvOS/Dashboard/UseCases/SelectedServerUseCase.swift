
import Foundation
import PIALibrary
import Combine

protocol SelectedServerUseCaseType {
    var selectedSever: ServerType { get }
    func getSelectedServer() -> AnyPublisher<ServerType, Never>
    func getHistoricalServers() -> [ServerType]
}

class SelectedServerUseCase: SelectedServerUseCaseType {
    
    private let serverProvider: ServerProviderType
    private let clientPreferences: ClientPreferencesType
    
    init(serverProvider: ServerProviderType, clientPreferences: ClientPreferencesType) {
        self.serverProvider = serverProvider
        self.clientPreferences = clientPreferences
    }
    
    var selectedSever: ServerType {
        return clientPreferences.selectedServer
    }
    
    func getSelectedServer() -> AnyPublisher<ServerType, Never> {
        return clientPreferences.getSelectedServer()

    }
    
    func getHistoricalServers() -> [ServerType] {
        return serverProvider.historicalServersType
    }
    
    static func automaticServer() -> ServerType {
        Server(
            serial: "",
            name: L10n.Localizable.Global.automatic,
            country: "universal",
            hostname: "auto.bogus.domain",
            pingAddress: nil,
            regionIdentifier: "auto"
        )
    }
}

