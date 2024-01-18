
import XCTest
@testable import PIA_VPN_tvOS

final class QuickConnectViewModelTests: XCTestCase {
    class Fixture {
        let connectUseCaseMock = VpnConnectionUseCaseMock()
        let selectedServerUseCaseMock = SelectedServerUseCaseMock()
        let serverMock = ServerMock()
    }
    
    var fixture: Fixture!
    var sut: QuickConnectViewModel!
    
    override func setUp() {
       fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
    }
    
    private func initilizeSut() {
        sut = QuickConnectViewModel(connectUseCase: fixture.connectUseCaseMock, selectedServerUseCase: fixture.selectedServerUseCaseMock)
    }
    
    func test_quickConnectServers_on_launch() {
        // GIVEN that there are 2 historical servers
        fixture.selectedServerUseCaseMock.getHistoricalServersResult = [ServerMock(), ServerMock()]
        
        // WHEN showing the Quick Connect section
        initilizeSut()
        sut.updateStatus()
        
        // THEN there are 2 Quick Connect buttons displayed
        XCTAssertEqual(sut.servers.count, 2)
    }
    
    
    func test_quickConnectButtonViewModelDelegate() {
        // GIVEN that the selected server is 'Italy-Milano'
        fixture.serverMock.country = "IT"
        fixture.serverMock.name = "Italy-Milano"
        
        initilizeSut()
        
        // WHEN the sut is informed via `QuickConnectButtonViewModelDelegate` to connect
        sut.quickConnectButtonViewModel(didSelect: fixture.serverMock)
        
        // THEN the vpn connect use case is called to connect to "Italy-Milano"
        XCTAssertTrue(fixture.connectUseCaseMock.connectToServerCalled)
        XCTAssertEqual(fixture.connectUseCaseMock.connectCalledToServerAttempt, 1)
        XCTAssertEqual(fixture.connectUseCaseMock.connectToServerCalledWithArgument?.name, "Italy-Milano")
    }
    
}
