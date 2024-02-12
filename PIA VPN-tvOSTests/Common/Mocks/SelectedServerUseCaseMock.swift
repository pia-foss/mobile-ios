
import Foundation
import Combine
@testable import PIA_VPN_tvOS

class SelectedServerUseCaseMock: SelectedServerUseCaseType {
    
    var getSelectedServerCalled = false
    var getSelectedServerAttempt = 0
    var getSelectedServerResult: CurrentValueSubject<ServerType, Never> = CurrentValueSubject(ServerMock())
    func getSelectedServer() -> AnyPublisher<PIA_VPN_tvOS.ServerType, Never> {
        getSelectedServerCalled = true
        getSelectedServerAttempt += 1
        return getSelectedServerResult.eraseToAnyPublisher()
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
