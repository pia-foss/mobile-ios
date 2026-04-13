import Combine
import Foundation
import PIALibrary
import PIALocalizations

public protocol SelectedServerUseCaseType {
    var selectedServer: ServerType { get }
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

    public var selectedServer: ServerType {
        return clientPreferences.selectedServer
    }

    public func getSelectedServer() -> AnyPublisher<ServerType, Never> {
        return clientPreferences.getSelectedServer()

    }

    public func getHistoricalServers() -> [ServerType] {
        return serverProvider.historicalServersType
    }

}
