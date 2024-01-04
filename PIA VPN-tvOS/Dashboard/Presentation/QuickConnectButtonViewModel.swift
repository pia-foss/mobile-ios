
import Foundation

protocol QuickConnectButtonViewModelDelegate: AnyObject {
    func quickConnectButtonViewModel(didSelect server: ServerType)
}

class QuickConnectButtonViewModel: ObservableObject {
    
    private let server: ServerType
    
    @Published var flagName = ""
    
    weak var delegate: QuickConnectButtonViewModelDelegate?
    
    init(server: ServerType, delegate: QuickConnectButtonViewModelDelegate?) {
        self.server = server
        self.delegate = delegate
        updateStatus()
    }
    
    func connectButtonDidTap() {
        delegate?.quickConnectButtonViewModel(didSelect: server)
    }
    
    private func updateStatus() {
        flagName = "flag-\(server.country.lowercased())"
    }
    
    
}
