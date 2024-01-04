
import Foundation
@testable import PIA_VPN_tvOS

class SelectedServerUseCaseMock: SelectedServerUseCaseType {
    var getSelectedServerCalled = false
    var getSelectedServerAttempt = 0
    var getSelectedServerResult: ServerType = ServerMock()
    
    func getSelectedServer() -> ServerType {
        getSelectedServerCalled = true
        getSelectedServerAttempt += 1
        return getSelectedServerResult
    }
    
    var getHistoricalServersCalled = false
    var getHistoricalServersttempt = 0
    var getHistoricalServersResult: [ServerType] = []
    
    func getHistoricalServers() -> [ServerType] {
        getHistoricalServersCalled = true
        getHistoricalServersttempt += 1
        return getHistoricalServersResult
    }
    
    
    
}
