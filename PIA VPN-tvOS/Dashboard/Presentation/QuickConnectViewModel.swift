
import Foundation

class QuickConnectViewModel: ObservableObject {
    
    @Published private (set) var servers: [ServerType] = []
    
    private let connectUseCase: VpnConnectionUseCaseType
    private let selectedServerUseCase: SelectedServerUseCaseType
    
    
    init(connectUseCase: VpnConnectionUseCaseType,
         selectedServerUseCase: SelectedServerUseCaseType) {
        self.connectUseCase = connectUseCase
        self.selectedServerUseCase = selectedServerUseCase
    }
    
    func updateStatus() {
        servers = selectedServerUseCase.getHistoricalServers().reversed()
    }
    
}

extension QuickConnectViewModel: QuickConnectButtonViewModelDelegate {
    
    func quickConnectButtonViewModel(didSelect server: ServerType) {
        connectUseCase.connect(to: server)
    }
    
}

