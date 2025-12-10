
import XCTest
@testable import PIALibrary

class LogoutUseCaseTests: XCTestCase {
    class Fixture {
        let networkClientMock = NetworkRequestClientMock()
        let apiTokenProviderMock = APITokenProviderMock()
        let vpnTokenProviderMock = VpnTokenProviderMock()
        let refreshAuthTokensCheckerMock = RefreshAuthTokensCheckerMock()
        
        func stubRefreshAuthTokensIfNeededWithError(_ error: NetworkRequestError?) {
            refreshAuthTokensCheckerMock.refreshIfNeededError = error
        }
        
    }
    
    var fixture: Fixture!
    var sut: LogoutUseCase!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = LogoutUseCase(networkClient: fixture.networkClientMock, apiTokenProvider: fixture.apiTokenProviderMock, vpnTokenProvider: fixture.vpnTokenProviderMock, refreshAuthTokensChecker: fixture.refreshAuthTokensCheckerMock)
    }
    
    func test_logout_when_refresh_tokens_returns_no_error() {
        // GIVEN that the auth tokens checker does not return any error
        fixture.stubRefreshAuthTokensIfNeededWithError(nil)
        
        instantiateSut()
        
        let expectation = expectation(description: "Logout call is finished")
        var capturedError: NetworkRequestError? = nil
        
        // WHEN calling logout
        sut() { error in
            capturedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the tokens are refreshed if needed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND the logout request executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.logout)
        
        // AND the API token and Vpn Token are removed
        XCTAssertEqual(fixture.apiTokenProviderMock.clearAPITokenCalledAttempt, 1)
        XCTAssertEqual(fixture.vpnTokenProviderMock.clearVpnTokenCalledAttempt, 1)
        
        // AND no error is returned
        XCTAssertNil(capturedError)
    }
    
    func test_logout_when_refresh_tokens_returns_an_error() {
        // GIVEN that the auth tokens checker returns an error
        fixture.stubRefreshAuthTokensIfNeededWithError(NetworkRequestError.allConnectionAttemptsFailed())
        
        instantiateSut()
        
        let expectation = expectation(description: "Logout call is finished")
        var capturedError: NetworkRequestError? = nil
        
        // WHEN calling logout
        sut() { error in
            capturedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN refresh tokens checker is called to refresh the tokens
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND the logout request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.logout)
        
        // AND the API token and Vpn Token are removed
        XCTAssertEqual(fixture.apiTokenProviderMock.clearAPITokenCalledAttempt, 1)
        XCTAssertEqual(fixture.vpnTokenProviderMock.clearVpnTokenCalledAttempt, 1)
        
        // AND no error is returned
        XCTAssertNil(capturedError)
    }
    
}
