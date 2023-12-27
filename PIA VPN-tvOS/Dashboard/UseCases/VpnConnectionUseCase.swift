
import Foundation

protocol VpnConnectionUseCaseType {
    func connect()
    func connect(to server: ServerType)
    func disconnect()
}

class VpnConnectionUseCase: VpnConnectionUseCaseType {
    
    let serverProvider: ServerProviderType
    
    init(serverProvider: ServerProviderType) {
        self.serverProvider = serverProvider
    }
    
    func connect() {
        // TODO: Implement
    }
    
    func disconnect() {
        // TODO: Implement
    }
    
    func connect(to server: ServerType) {
        // TODO: Implement me
        print("VpnConnectionUseCase: connect to: \(server.name)")
    }
    
    
    
}
