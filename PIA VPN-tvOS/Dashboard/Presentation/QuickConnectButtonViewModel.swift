import Foundation
import PIAAssetsTV
import PIALibrary
import struct SwiftUI.Image

protocol QuickConnectButtonViewModelDelegate: AnyObject {
    func quickConnectButtonViewModel(didSelect server: ServerType)
}

class QuickConnectButtonViewModel: ObservableObject {
    
    private let server: ServerType
    private let getDedicatedIpUseCase: GetDedicatedIpUseCaseType
    
    
    var flagImage: Image {
        if getDedicatedIpUseCase.isDedicatedIp(server) {
            return Asset.iconDipLocation.swiftUIImage
        }
        return Asset.flag(forCountry: server.country) ?? Asset.iconSmartLocation.swiftUIImage
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
