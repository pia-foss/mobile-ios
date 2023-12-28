
import Foundation
import PIALibrary

protocol SelectedServerUseCaseType {
    func getSelectedServer() -> ServerType
    func getHistoricalServers() -> [ServerType]
}

class SelectedServerUseCase: SelectedServerUseCaseType {
    
    let serverProvider: ServerProviderType
    
    init(serverProvider: ServerProviderType) {
        self.serverProvider = serverProvider
    }
    
    func getSelectedServer() -> ServerType {
        // TODO: get real selected server
        return automaticServer()
    }
    
    func getHistoricalServers() -> [ServerType] {
        // TODO: Remove this `guard` statement when we get
        // the real historical servers
        guard !serverProvider.historicalServers.isEmpty else {
            return Self.generateDemoServers()
        }
        return serverProvider.historicalServers
    }
    
    private func automaticServer() -> ServerType {
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

// TODO: Remove this extension when we have implemented
// getting the real historical servers (for QuickConnect)
extension SelectedServerUseCase {
    private static func generateDemoServers() -> [ServerType] {
        var servers: [ServerType] = []
        func createDemoServer(name: String, country: String, regionIdentifier: String) -> ServerType {
            Server(serial: "", name: name, country: country, hostname: "auto.bogus.domain", pingAddress: nil, regionIdentifier: regionIdentifier)
        }
        
        servers.append(createDemoServer(name: "Spain", country: "ES", regionIdentifier: "Spain"))
        servers.append(createDemoServer(name: "France", country: "FR", regionIdentifier: "France"))
        servers.append(createDemoServer(name: "Germany", country: "DE", regionIdentifier: "Germany"))
        servers.append(createDemoServer(name: "Netherlands", country: "NL", regionIdentifier: "Netherlands"))
        servers.append(createDemoServer(name: "Australia", country: "AU", regionIdentifier: "Australia"))
        servers.append(createDemoServer(name: "Portugal", country: "PT", regionIdentifier: "Portugal"))
        servers.append(createDemoServer(name: "Ireland", country: "IR", regionIdentifier: "Ireland"))
        servers.append(createDemoServer(name: "Italy", country: "IT", regionIdentifier: "Italy"))
        servers.append(createDemoServer(name: "Canada", country: "CA", regionIdentifier: "Canada"))
    
        
        return servers
        
    }
}
