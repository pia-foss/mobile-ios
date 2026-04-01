
import XCTest
@testable import PIALibrary

final class RenewDedicatedIPUseCaseTests: XCTestCase {
    class Fixture {
        var networkClientMock = NetworkRequestClientMock()
        let refreshAuthTokensCheckerMock = RefreshAuthTokensCheckerMock()
        
        func stubRequestWithResponse(_ response: NetworkRequestResponseType) {
            networkClientMock.executeRequestResponse = response
        }
        
        func stubRequestWithError(_ error: NetworkRequestError) {
            networkClientMock.executeRequestError = error
        }
    }
    
    var fixture: Fixture!
    var sut: RenewDedicatedIPUseCase!
    var capturedResult: Result<Void, NetworkRequestError>!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        capturedResult = nil
    }
    
    private func instantiateSut() {
        sut = RenewDedicatedIPUseCase(networkClient: fixture.networkClientMock,
                                      refreshAuthTokensChecker: fixture.refreshAuthTokensCheckerMock)
    }
    
    func test_renewDedicatedIPs_completes_with_success_when_there_is_no_error() {
        // GIVEN Network client completes with no error
        fixture.stubRequestWithResponse(NetworkRequestResponseStub(data: nil))
        instantiateSut()
        
        let expectation = expectation(description: "Waiting for renew dedicated IP to finish")
        
        // WHEN renewDedicatedIPs is executed
        sut(dipToken: "dipToken") { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with success
        wait(for: [expectation], timeout: 1.0)
        guard case .success = capturedResult else {
            XCTFail("Expected success, got failure")
            return
        }
    }
    
    func test_renewDedicatedIPs_completes_with_an_unauthorized_error_when_there_is_401_status_code() {
        // GIVEN Network client completes with an 401 status code error
        instantiateSut()
        fixture.stubRequestWithError(.connectionError(statusCode: 401, message: "any message"))
        let expectation = expectation(description: "Waiting for renew dedicated IP to finish")
        
        // WHEN renewDedicatedIPs is executed
        sut(dipToken: "dipToken") { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with unauthorized error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure got success")
            return
        }
        
        XCTAssertEqual(error, .unauthorized)
    }
    
    func test_renewDedicatedIPs_completes_with_an_error_when_network_client_completes_with_a_non_401_error() {
        // GIVEN Network client completes with a non 401 error
        fixture.stubRequestWithError(.allConnectionAttemptsFailed(statusCode: 404))
        instantiateSut()
        
        let expectation = expectation(description: "Waiting for renew dedicated IP to finish")
        
        // WHEN renewDedicatedIPs is executed
        sut(dipToken: "dipToken") { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with allConnectionAttemptsFailed error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure got success")
            return
        }
        
        XCTAssertEqual(error, .allConnectionAttemptsFailed(statusCode: 404))
    }

    func test_renewDedicatedIPs_creates_valid_networkConfiguration() {
        // GIVEN
        let expectedBody = try? JSONEncoder().encode(["token": "001"])
        instantiateSut()
        
        // WHEN renewDedicatedIPs is executed
        sut.callAsFunction(dipToken: "001") { _ in }
        
        // THEN
        guard let capturedConfiguration = fixture.networkClientMock.executeRequestWithConfiguation as? RenewDedicatedIPRequestConfiguration else {
            XCTFail("Expected RenewDedicatedIPRequestConfiguration configuration")
            return
        }
        
        XCTAssertEqual(capturedConfiguration.networkRequestModule, .account)
        XCTAssertEqual(capturedConfiguration.path, .renewDedicatedIp)
        XCTAssertEqual(capturedConfiguration.httpMethod, .post)
        XCTAssertTrue(capturedConfiguration.inlcudeAuthHeaders)
        XCTAssertEqual(capturedConfiguration.contentType, .json)
        XCTAssertNil(capturedConfiguration.urlQueryParameters)
        XCTAssertEqual(capturedConfiguration.responseDataType, .jsonData)
        XCTAssertEqual(capturedConfiguration.timeout, 10)
        XCTAssertEqual(capturedConfiguration.body?.count, expectedBody?.count)
    }

}
