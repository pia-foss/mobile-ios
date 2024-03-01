

import XCTest
@testable import PIA_VPN_tvOS

final class QuickConnectButtonViewModelTests: XCTestCase {

    class Fixture {
        let serverMock = ServerMock()
        let getDedicatedIpUseCaseMock = GetDedicatedIpUseCaseMock(result: nil)
        let spyDelegate = QuickConnectButtonViewModelDelegateMock()
    }
    
    var fixture: Fixture!
    var sut: QuickConnectButtonViewModel!

    override func setUp() {
        fixture = Fixture()
       
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    
    private func initializeSut() {
        sut = QuickConnectButtonViewModel(server: fixture.serverMock, getDedicatedIpUseCase: fixture.getDedicatedIpUseCaseMock, delegate: fixture.spyDelegate)
    }
    
    func test_displayedFlag_whenButtonCreated() {
        // GIVEN that the server country is 'ES'
        fixture.serverMock.country = "ES"
        
        // WHEN the Quick Connect button is created
        initializeSut()
        
        // THEN the flag displayed is 'flag-es'
        XCTAssertEqual(sut.flagName, "flag-es")
        
    }
    
    func test_quickConnectButtonAction() {
        // GIVEN that the server is "Canada-Toronto"
        fixture.serverMock.country = "CA"
        fixture.serverMock.name = "Canada-Toronto"
        
        initializeSut()
        
        // WHEN tapping the Quick Connect Button
        sut.connectButtonDidTap()
        
        // THEN the delegate is called ONE time with the "Canada-Toronto" server
        XCTAssertTrue(fixture.spyDelegate.quickConnectButtonViewModelDelegateDidSelectServerCalled)
        XCTAssertEqual(fixture.spyDelegate.quickConnectButtonViewModelDelegateDidSelectServerAttempt, 1)
        XCTAssertEqual(fixture.spyDelegate.quickConnectButtonViewModelDelegateDidSelectServerCalledWithServer?.name, "Canada-Toronto")
        
    }

}
