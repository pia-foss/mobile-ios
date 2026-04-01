
import XCTest
@testable import PIA_VPN_tvOS

final class QuickConnectViewModelTests: XCTestCase {
    class Fixture {
        let selectedServerUseCaseMock = SelectedServerUseCaseMock()
        let regionsUseCaseMock = RegionsListUseCaseMock()
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
        sut = QuickConnectViewModel(selectedServerUseCase: fixture.selectedServerUseCaseMock, regionsUseCase: fixture.regionsUseCaseMock)
    }
    
    func test_quickConnectServers_on_launch() {
        // GIVEN that there are 2 historical servers (the first one is the current selected server)
        fixture.selectedServerUseCaseMock.getHistoricalServersResult = [ServerMock(), ServerMock()]
        
        // WHEN showing the Quick Connect section
        initilizeSut()
        sut.updateStatus()
        
        // THEN there is 1 Quick Connect button displayed
        XCTAssertEqual(sut.servers.count, 1)
    }
    
    
    func test_quickConnectButtonViewModelDelegate() {
        // GIVEN that the selected server is 'Italy-Milano'
        fixture.serverMock.country = "IT"
        fixture.serverMock.name = "Italy-Milano"
        
        initilizeSut()
        
        // WHEN the sut is informed via `QuickConnectButtonViewModelDelegate` to connect
        sut.quickConnectButtonViewModel(didSelect: fixture.serverMock)
        
        // THEN the regions use case is called to select the "Italy-Milano" server
        XCTAssertTrue(fixture.regionsUseCaseMock.selectServerCalled)
        XCTAssertEqual(fixture.regionsUseCaseMock.selectServerCalledWithArgument!.name, "Italy-Milano")
  

    }
    
}
