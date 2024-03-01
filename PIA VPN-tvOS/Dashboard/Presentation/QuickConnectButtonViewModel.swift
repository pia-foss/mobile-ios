
import Foundation

protocol QuickConnectButtonViewModelDelegate: AnyObject {
    func quickConnectButtonViewModel(didSelect server: ServerType)
}

class QuickConnectButtonViewModel: ObservableObject {
    
    private let server: ServerType
    private let getDedicatedIpUseCase: GetDedicatedIpUseCaseType
    
    
    var flagName: String {
        let isDipServer = getDedicatedIpUseCase.isDedicatedIp(server)
        if isDipServer {
            return .icon_dip_location
        } else {
           return "flag-\(server.country.lowercased())"
        }
        
    }
    
    var titleText: String {
        server.country.uppercased()
    }
    
    weak var delegate: QuickConnectButtonViewModelDelegate?
    
    init(server: ServerType, getDedicatedIpUseCase: GetDedicatedIpUseCaseType, delegate: QuickConnectButtonViewModelDelegate?) {
        self.server = server
        self.getDedicatedIpUseCase = getDedicatedIpUseCase
        self.delegate = delegate
        
    }
    
    func connectButtonDidTap() {
        delegate?.quickConnectButtonViewModel(didSelect: server)
    }
    

    
    
}
