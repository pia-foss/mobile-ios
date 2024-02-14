
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
        let allHistoricalServers = selectedServerUseCase.getHistoricalServers().reversed().dropFirst()
        servers = Array(allHistoricalServers.prefix(4))
    }
    
}

extension QuickConnectViewModel: QuickConnectButtonViewModelDelegate {
    
    func quickConnectButtonViewModel(didSelect server: ServerType) {
        regionsUseCase.select(server: server)
        updateStatus()
    }
    
}

