
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
    let vpnStatusMonitor: VPNStatusMonitorType
    private var cancellables = Set<AnyCancellable>()
    
    init(serverProvider: ServerProviderType, vpnProvider: VPNStatusProviderType, vpnStatusMonitor: VPNStatusMonitorType) {
        self.serverProvider = serverProvider
        self.vpnProvider = vpnProvider
        self.vpnStatusMonitor = vpnStatusMonitor
        self.connectionIntent = CurrentValueSubject(.none)
        
        subscribeToVpnStatusState()
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


// MARK: - VPN Status subscription

extension VpnConnectionUseCase {
    func subscribeToVpnStatusState() {
        vpnStatusMonitor.getStatus()
            .receive(on: RunLoop.main)
            .sink { [weak self] newVpnStatus in
                guard let self else { return }
                var newConnectionIntent = VpnConnectionIntent.none
                let currentConnectionIntent = self.connectionIntent.value
                
                switch (currentConnectionIntent, newVpnStatus) {
                case (.connect, .connected):
                    // The vpn connection has succeeded, then put back the connection intent to none
                    self.connectionIntent.send(.none)
                case (.disconnect, .disconnected):
                    // The vpn disconnect has succeeded, then put back the connection intent to none
                    self.connectionIntent.send(.none)
                default:
                    break

                }
            }.store(in: &cancellables)
            
    }
}
