
import XCTest
@testable import PIALibrary

class ClientStatusUseCaseTests: XCTestCase {
    class Fixture {
        let networkClientMock = NetworkRequestClientMock()
        let refreshAuthTokensCheckerMock = RefreshAuthTokensCheckerMock()
        let clientStatusDecoderMock = ClientStatusDecoderMock()
        let clientStatusInfo = ClientStatusInformation(connected: true, ip: "111.11.11.11")
        
        func stubClientStatusInfoSuccessfulResponse() {
            let response = NetworkRequestResponseMock(statusCode: 200, data: Data())
            networkClientMock.executeRequestResponse = response
        }
        
        func stubClientStatusInfoResponseWithNoData() {
            let response = NetworkRequestResponseMock(statusCode: 200, data: nil)
            networkClientMock.executeRequestResponse = response
        }
        
        func stubClientStatusInfoResponseError(_ error: NetworkRequestError) {
            networkClientMock.executeRequestError = error
        }
        
        func stubRefreshAuthTokensError(_ error: NetworkRequestError) {
            refreshAuthTokensCheckerMock.refreshIfNeededError = error
        }
        
        func stubDecodeClientStatusInfo(as info: ClientStatusInformation?) {
            clientStatusDecoderMock.decodeClientStatusResult = info
        }
        
        
    }
    
    var fixture: Fixture!
    var sut: ClientStatusUseCase!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = ClientStatusUseCase(networkClient: fixture.networkClientMock, refreshAuthTokensChecker: fixture.refreshAuthTokensCheckerMock, clientStatusDecoder: fixture.clientStatusDecoderMock)
    }
    
    func test_clientStatusInfo_when_request_succeeds() {
        // GIVEN that the request to get the client status info succeeds
        fixture.stubClientStatusInfoSuccessfulResponse()
        fixture.stubDecodeClientStatusInfo(as: fixture.clientStatusInfo)
        
        instantiateSut()
        
        var capturedError: NetworkRequestError?
        var capturedClientStatus: ClientStatusInformation?
        let expectation = expectation(description: "client status request is executed")
        
        // WHEN getting the client status
        sut.callAsFunction { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let statusInfo):
                capturedClientStatus = statusInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the clientStatus request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.clientStatus)
        
        // AND the auth tokens are refreshed if needed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND the client status info is returned
        XCTAssertEqual(capturedClientStatus!, fixture.clientStatusInfo)
        
        // AND no error is returned
        XCTAssertNil(capturedError)
    }
    
    func test_clientStatusInfo_when_request_fails() {
        // GIVEN that the request to get the client status info fails
        fixture.stubClientStatusInfoResponseError(.allConnectionAttemptsFailed(statusCode: 401))
        
        instantiateSut()
        
        var capturedError: NetworkRequestError?
        var capturedClientStatus: ClientStatusInformation?
        let expectation = expectation(description: "client status request is executed")
        
        // WHEN getting the client status
        sut.callAsFunction { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let statusInfo):
                capturedClientStatus = statusInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the clientStatus request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.clientStatus)
        
        // AND the auth tokens are refreshed if needed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .allConnectionAttemptsFailed(statusCode: 401))
        
        // AND NO client status info is returned
        XCTAssertNil(capturedClientStatus)
    }
    
    func test_clientStatusInfo_when_request_fails_withNoData() {
        // GIVEN that the request to get the client status returns no Data
        fixture.stubClientStatusInfoResponseWithNoData()
        
        instantiateSut()
        
        var capturedError: NetworkRequestError?
        var capturedClientStatus: ClientStatusInformation?
        let expectation = expectation(description: "client status request is executed")
        
        // WHEN getting the client status
        sut.callAsFunction { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let statusInfo):
                capturedClientStatus = statusInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the clientStatus request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.clientStatus)
        
        // AND the auth tokens are refreshed if needed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .noDataContent)
        
        // AND NO client status info is returned
        XCTAssertNil(capturedClientStatus)
    }
    
    func test_clientStatusInfo_when_decoding_fails() {
        // GIVEN that the request to get the client status info succeeds
        fixture.stubClientStatusInfoSuccessfulResponse()
        // AND decoding the client status info fails
        fixture.stubDecodeClientStatusInfo(as: nil)
        
        instantiateSut()
        
        var capturedError: NetworkRequestError?
        var capturedClientStatus: ClientStatusInformation?
        let expectation = expectation(description: "client status request is executed")
        
        // WHEN getting the client status
        sut.callAsFunction { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let statusInfo):
                capturedClientStatus = statusInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the clientStatus request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.clientStatus)
        
        // AND the auth tokens are refreshed if needed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .unableToDecodeData)
        
        // AND NO client status info is returned
        XCTAssertNil(capturedClientStatus)
    }
    
    func test_clientStatusInfo_when_refreshing_tokens_fail() {
        // GIVEN that refreshing auth tokens request fails
        fixture.stubRefreshAuthTokensError(.allConnectionAttemptsFailed(statusCode: 401))
        
        // AND GIVEN that the request to get the client status info succeeds
        fixture.stubClientStatusInfoSuccessfulResponse()
        fixture.stubDecodeClientStatusInfo(as: fixture.clientStatusInfo)
        
        instantiateSut()
        
        var capturedError: NetworkRequestError?
        var capturedClientStatus: ClientStatusInformation?
        let expectation = expectation(description: "client status request is executed")
        
        // WHEN getting the client status
        sut.callAsFunction { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let statusInfo):
                capturedClientStatus = statusInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the clientStatus request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.clientStatus)
        
        // AND the auth tokens are refreshed if needed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND an error is NOT returned
        XCTAssertNil(capturedError)
        
        // AND the client status info is returned
        XCTAssertNotNil(capturedClientStatus)
        XCTAssertEqual(capturedClientStatus!, fixture.clientStatusInfo)
    }
    
}
