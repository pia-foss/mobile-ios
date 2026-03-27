import Combine
import Foundation
import PIADashboard
import PIALibrary

@testable import PIA_VPN_tvOS

class SelectedServerUseCaseMock: SelectedServerUseCaseType {

    var selectedServer: ServerType = ServerMock()

    var getSelectedServerCalled = false
    var getSelectedServerAttempt = 0
    var getSelectedServerResult: CurrentValueSubject<ServerType, Never> = CurrentValueSubject(ServerMock())
    func getSelectedServer() -> AnyPublisher<ServerType, Never> {
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
