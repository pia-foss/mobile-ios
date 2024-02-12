
import Foundation
import PIALibrary
import Combine

protocol VpnConnectionUseCaseType {
    func connect() async throws
    func connect(to server: ServerType)
    func disconnect() async throws
    func getConnectionIntent() -> AnyPublisher<VpnConnectionIntent, Error>
}

enum VpnConnectionIntent: Equatable {
    case none
    case connect
    case disconnect
    case reconnect
}

class VpnConnectionUseCase: VpnConnectionUseCaseType {
    
    private var connectionIntent: CurrentValueSubject<VpnConnectionIntent, Error>
    
    let serverProvider: ServerProviderType
    
    init(serverProvider: ServerProviderType) {
        self.serverProvider = serverProvider
        self.connectionIntent = CurrentValueSubject(.none)
    }
    

    func vpnStatusWasUpdated(to vpnStatus: VPNStatus) {
        let connectionIntent = connectionIntent.value
        switch (connectionIntent, vpnStatus) {
        case (.connect, .connected):
            self.connectionIntent.send(.none)
        case (.disconnect, .disconnected):
            self.connectionIntent.send(.none)
        default:
            break
        }
    }
    
    func connect() async throws {
       
        connectionIntent.send(.connect)
        
        return try await withCheckedThrowingContinuation { continuation in
            // TODO: Inject VPNProvider object
            let vpnProvider = Client.providers.vpnProvider
            vpnProvider.connect { error in
                if let error = error {
                    self.connectionIntent.send(completion: .failure(error))
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    
    func disconnect() async throws {

        connectionIntent.send(.disconnect)
        
        return try await withCheckedThrowingContinuation { continuation in
            // TODO: Inject VPNProvider object
            let vpnProvider = Client.providers.vpnProvider
            vpnProvider.disconnect { error in
                if let error = error {
                    self.connectionIntent.send(completion: .failure(error))
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    // TODO: This is a select server and connect (same as from regions list)
    func connect(to server: ServerType) {
        // TODO: Implement me
        NSLog("VpnConnectionUseCase: connect to: \(server.name)")
    }
    
    func getConnectionIntent() -> AnyPublisher<VpnConnectionIntent, Error> {
        return connectionIntent.eraseToAnyPublisher()
    }
    
}
