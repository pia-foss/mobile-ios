
import Foundation
import PIALibrary

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
        // TODO: Inject VPNProvider object
        let vpnProvider = Client.providers.vpnProvider
        vpnProvider.connect { error in
            NSLog("Connection error: \(error)")
        }
    }
    
    func disconnect() {
        // TODO: Inject VPNProvider object
        let vpnProvider = Client.providers.vpnProvider
        vpnProvider.disconnect { error in
            NSLog("Disconnect error: \(error)")
        }
        
    }
    
    func connect(to server: ServerType) {
        // TODO: Implement me
        print("VpnConnectionUseCase: connect to: \(server.name)")
    }
    
    
    
}
