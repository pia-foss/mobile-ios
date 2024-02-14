
import Foundation
import PIALibrary
import Combine

protocol VpnConnectionUseCaseType {
    func connect() async throws
    func disconnect() async throws
    func getConnectionIntent() -> AnyPublisher<VpnConnectionIntent, Error>
}

enum VpnConnectionIntent: Equatable {
    case none
    case connect
    case disconnect
}

class VpnConnectionUseCase: VpnConnectionUseCaseType {
    
    internal var connectionIntent: CurrentValueSubject<VpnConnectionIntent, Error>
    
    let serverProvider: ServerProviderType
    let vpnProvider: VPNStatusProviderType
    
    init(serverProvider: ServerProviderType, vpnProvider: VPNStatusProviderType) {
        self.serverProvider = serverProvider
        self.vpnProvider = vpnProvider
        self.connectionIntent = CurrentValueSubject(.none)
    }
    
    func connect() async throws {
       
        connectionIntent.send(.connect)
        
        return try await withCheckedThrowingContinuation { continuation in
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
  
    func getConnectionIntent() -> AnyPublisher<VpnConnectionIntent, Error> {
        return connectionIntent.eraseToAnyPublisher()
    }
    
}
