import XCTest
@testable import PIALibrary

class DeleteAccountUseCaseTests: XCTestCase {
    class Fixture {
        let networkClientMock = NetworkRequestClientMock()
        let refreshAuthTokenCheckerMock = RefreshAuthTokensCheckerMock()
        let apiTokenProviderMock = APITokenProviderMock()
        let vpnTokenProviderMock = VpnTokenProviderMock()
        
        func stubNetworkRequestSuccessfulResponse() {
            networkClientMock.executeRequestResponse = NetworkRequestResponseMock(statusCode: 200)
            networkClientMock.executeRequestError = nil
        }
        
        func stubNetworkRequestResponseWithError(_ error: NetworkRequestError) {
            networkClientMock.executeRequestError = error
        }
        
        func stubRefreshAuthTokensWithSuccess() {
            refreshAuthTokenCheckerMock.refreshIfNeededError = nil
        }
        
        func stubRefreshAuthTokensFailsWithError(_ error: NetworkRequestError) {
            refreshAuthTokenCheckerMock.refreshIfNeededError = error
        }
    }
    
    var fixture: Fixture!
    var sut: DeleteAccountUseCase!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = DeleteAccountUseCase(networkClient: fixture.networkClientMock, refreshAuthTokenChecker: fixture.refreshAuthTokenCheckerMock, apiTokenProvider: fixture.apiTokenProviderMock, vpnTokenProvider: fixture.vpnTokenProviderMock)
    }
    
    func test_delete_account_when_network_request_succeeds() {
        // GIVEN that the network request succeeds
        fixture.stubNetworkRequestSuccessfulResponse()
        // AND refreshing the auth tokens also succeeds
        fixture.stubRefreshAuthTokensWithSuccess()
        
        instantiateSut()
        
        let expectation = expectation(description: "Delete account request is executed")
        var capturedError: NetworkRequestError?
        // WHEN exectuting the delete account request
        sut() { error in
            capturedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the refresh auth tokens if needed request is called
        XCTAssertEqual(fixture.refreshAuthTokenCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequest = fixture.networkClientMock.executeRequestWithConfiguation!
        // AND the delete account request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequest.path, RequestAPI.Path.deleteAccount)
        XCTAssertEqual(executedRequest.httpMethod, .delete)
        
        // AND no error is retured
        XCTAssertNil(capturedError)
        
        // AND the auth tokens ARE removed
        XCTAssertEqual(fixture.apiTokenProviderMock.clearAPITokenCalledAttempt, 1)
        XCTAssertEqual(fixture.vpnTokenProviderMock.clearVpnTokenCalledAttempt, 1)
        
    }
    
    func test_delete_account_when_network_request_fails() {
        // GIVEN that the network request fails
        fixture.stubNetworkRequestResponseWithError(.allConnectionAttemptsFailed(statusCode: 401))
        // AND refreshing the auth tokens succeeds
        fixture.stubRefreshAuthTokensWithSuccess()
        
        instantiateSut()
        
        let expectation = expectation(description: "Delete account request is executed")
        var capturedError: NetworkRequestError?
        // WHEN exectuting the delete account request
        sut() { error in
            capturedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the refresh auth tokens if needed request is called
        XCTAssertEqual(fixture.refreshAuthTokenCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequest = fixture.networkClientMock.executeRequestWithConfiguation!
        // AND the delete account request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequest.path, RequestAPI.Path.deleteAccount)
        XCTAssertEqual(executedRequest.httpMethod, .delete)
        
        // AND an error IS retured
        XCTAssertNotNil(capturedError)
        
        // AND the auth tokens are NOT removed
        XCTAssertEqual(fixture.apiTokenProviderMock.clearAPITokenCalledAttempt, 0)
        XCTAssertEqual(fixture.vpnTokenProviderMock.clearVpnTokenCalledAttempt, 0)
        
    }
    
    func test_delete_account_when_refreshAuthTokens_request_fails() {
        
        // GIVEN that refreshing the auth tokens fails
        fixture.stubRefreshAuthTokensFailsWithError(.allConnectionAttemptsFailed(statusCode: 401))
        
        instantiateSut()
        
        let expectation = expectation(description: "Delete account request is executed")
        var capturedError: NetworkRequestError?
        // WHEN exectuting the delete account request
        sut() { error in
            capturedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the refresh auth tokens if needed request is called
        XCTAssertEqual(fixture.refreshAuthTokenCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND the delete account request is NOT executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 0)
        
        // AND an error IS retured
        XCTAssertNotNil(capturedError)
        
        // AND the auth tokens are NOT removed
        XCTAssertEqual(fixture.apiTokenProviderMock.clearAPITokenCalledAttempt, 0)
        XCTAssertEqual(fixture.vpnTokenProviderMock.clearVpnTokenCalledAttempt, 0)
        
    }
    
}
