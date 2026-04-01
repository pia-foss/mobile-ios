
import Foundation

class QuickConnectViewModel: ObservableObject {
    
    @Published private (set) var servers: [ServerType] = []
    
    private let selectedServerUseCase: SelectedServerUseCaseType
    private let regionsUseCase: RegionsListUseCaseType
    
    
    init(selectedServerUseCase: SelectedServerUseCaseType,
         regionsUseCase: RegionsListUseCaseType) {
        self.selectedServerUseCase = selectedServerUseCase
        self.regionsUseCase = regionsUseCase
    }
    
    func updateStatus() {

        var allHistoricalServers: [ServerType] = Array(selectedServerUseCase.getHistoricalServers().reversed())
        
        // When the selected server is not Automatic, then the first element of the historical servers is the selected one
        if !selectedServerUseCase.selectedSever.isAutomatic && !allHistoricalServers.isEmpty {
            allHistoricalServers.removeFirst()
            
        }
        servers = Array(allHistoricalServers.prefix(4))
    }
    
}

extension QuickConnectViewModel: QuickConnectButtonViewModelDelegate {
    
    func quickConnectButtonViewModel(didSelect server: ServerType) {
        regionsUseCase.select(server: server)
        updateStatus()
    }
    
}

