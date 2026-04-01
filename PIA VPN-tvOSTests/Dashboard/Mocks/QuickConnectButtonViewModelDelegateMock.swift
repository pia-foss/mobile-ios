
import Foundation
@testable import PIA_VPN_tvOS

class QuickConnectButtonViewModelDelegateMock: QuickConnectButtonViewModelDelegate {
    
    var quickConnectButtonViewModelDelegateDidSelectServerCalled = false
    var quickConnectButtonViewModelDelegateDidSelectServerAttempt = 0
    var quickConnectButtonViewModelDelegateDidSelectServerCalledWithServer: ServerType?
    
    func quickConnectButtonViewModel(didSelect server: ServerType) {
        quickConnectButtonViewModelDelegateDidSelectServerCalled = true
        quickConnectButtonViewModelDelegateDidSelectServerAttempt += 1
        quickConnectButtonViewModelDelegateDidSelectServerCalledWithServer = server
        
    }
    
    
}
