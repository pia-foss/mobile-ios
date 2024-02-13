
import Foundation

protocol QuickConnectButtonViewModelDelegate: AnyObject {
    func quickConnectButtonViewModel(didSelect server: ServerType)
}

class QuickConnectButtonViewModel: ObservableObject {
    
    private let server: ServerType
    
    
    var flagName: String {
        "flag-\(server.country.lowercased())"
    }
    
    var titleText: String {
        server.country.uppercased()
    }
    
    weak var delegate: QuickConnectButtonViewModelDelegate?
    
    init(server: ServerType, delegate: QuickConnectButtonViewModelDelegate?) {
        self.server = server
        self.delegate = delegate
        
    }
    
    func connectButtonDidTap() {
        delegate?.quickConnectButtonViewModel(didSelect: server)
    }
    

    
    
}
