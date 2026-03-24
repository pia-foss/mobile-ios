
import Foundation
import PIALibrary
import Combine
import PIALocalizations

public protocol SelectedServerUseCaseType {
    var selectedSever: ServerType { get }
    func getSelectedServer() -> AnyPublisher<ServerType, Never>
    func getHistoricalServers() -> [ServerType]
}

public final class SelectedServerUseCase: SelectedServerUseCaseType {

    private let serverProvider: ServerProviderType
    private let clientPreferences: ClientPreferencesType
    
    public init(serverProvider: ServerProviderType, clientPreferences: ClientPreferencesType) {
        self.serverProvider = serverProvider
        self.clientPreferences = clientPreferences
    }
    
    public var selectedSever: ServerType {
        return clientPreferences.selectedServer
    }
    
    public func getSelectedServer() -> AnyPublisher<ServerType, Never> {
        return clientPreferences.getSelectedServer()

    }
    
    public func getHistoricalServers() -> [ServerType] {
        return serverProvider.historicalServersType
    }
    

}

