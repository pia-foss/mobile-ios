
import XCTest
@testable import PIALibrary

class AccountDetailsUseCaseTests: XCTestCase {
    class Fixture {
        let networkClientMock = NetworkRequestClientMock()
        let refreshAuthTokensCheckerMock = RefreshAuthTokensCheckerMock()
        let accountInfoDecoderMock = AccountInfoDecoderMock()
        let validAccountInfo = AccountInfo(username: "username", plan: .trial, productId: nil, isRenewable: true, isRecurring: false, expirationDate: Date.init(timeIntervalSinceNow: 1000), canInvite: true, shouldPresentExpirationAlert: false, renewUrl: nil)
        
        
        func stubSuccessfulAccountDetailsResponse() {
            let accountData = try? JSONEncoder().encode(self.validAccountInfo)
            let dataResponse = NetworkRequestResponseMock(statusCode: 200, data: accountData)
            networkClientMock.executeRequestError = nil
            networkClientMock.executeRequestResponse = dataResponse
        }
        
        func stubNoDataOnAccountDetailsResponse() {
            let dataResponse = NetworkRequestResponseMock(statusCode: 200, data: nil)
            networkClientMock.executeRequestError = nil
            networkClientMock.executeRequestResponse = dataResponse
        }
        
        
        func stubErrorAccountDetailsResponse(_ error: NetworkRequestError?) {
            networkClientMock.executeRequestError = error
        }
        
        func stubDecodeAccountInfoDataSuccessfully() {
            accountInfoDecoderMock.decodeAccountInfoResult = validAccountInfo
        }
        
        func stubUnableToDecodeAccountInfoData() {
            accountInfoDecoderMock.decodeAccountInfoResult = nil
        }
        
        func stubErrorRefreshingAuthTokens() {
            refreshAuthTokensCheckerMock.refreshIfNeededError = .allConnectionAttemptsFailed(statusCode: 401)
        }
    }
    
    var fixture: Fixture!
    var sut: AccountDetailsUseCase!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = AccountDetailsUseCase(networkClient: fixture.networkClientMock, refreshAuthTokensChecker: fixture.refreshAuthTokensCheckerMock, accountInforDecoder: fixture.accountInfoDecoderMock)
    }
    
    func test_getAccountDetails_when_expected_data_is_returned() {
        // GIVEN that the network request returns expected data
        fixture.stubSuccessfulAccountDetailsResponse()
        fixture.stubDecodeAccountInfoDataSuccessfully()
        instantiateSut()
        
        let expectation = expectation(description: "Account Details request is executed")
        var capturedError: NetworkRequestError?
        var capturedAccountDetails: AccountInfo?
        
        // WHEN getting the account details
        sut() { result in
            switch result {
            case .success(let accountInfo):
                capturedAccountDetails = accountInfo
            case .failure(let error):
                capturedError = error
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the auth tokens are refreshed if needed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND the account details request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.accountDetails)
        
        
        // AND no error is returned
        XCTAssertNil(capturedError)
        
        // AND the Account info is returned
        XCTAssertEqual(capturedAccountDetails, fixture.validAccountInfo)
        
    }
    
    func test_getAccountDetails_when_unable_to_decode_response_data() {
        // GIVEN that the decoder is NOT able to decode the data from the response
        fixture.stubSuccessfulAccountDetailsResponse()
        fixture.stubUnableToDecodeAccountInfoData()
        instantiateSut()
        
        let expectation = expectation(description: "Account Details request is executed")
        var capturedError: NetworkRequestError?
        var capturedAccountDetails: AccountInfo?
        
        // WHEN getting the account details
        sut() { result in
            switch result {
            case .success(let accountInfo):
                capturedAccountDetails = accountInfo
            case .failure(let error):
                capturedError = error
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the account details request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.accountDetails)
        
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        
        // AND the Account info is NOT returned
        XCTAssertNil(capturedAccountDetails)
        
    }
    
    func test_getAccountDetails_when_request_returns_an_error() {
        // GIVEN that the account details request returns an error
        fixture.stubErrorAccountDetailsResponse(.allConnectionAttemptsFailed(statusCode: 401))
        instantiateSut()
        
        let expectation = expectation(description: "Account Details request is executed")
        var capturedError: NetworkRequestError?
        var capturedAccountDetails: AccountInfo?
        
        // WHEN getting the account details
        sut() { result in
            switch result {
            case .success(let accountInfo):
                capturedAccountDetails = accountInfo
            case .failure(let error):
                capturedError = error
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the account details request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.accountDetails)
        
        
        // AND an 401 error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .allConnectionAttemptsFailed(statusCode: 401))
        
        // AND the Account info is NOT returned
        XCTAssertNil(capturedAccountDetails)
        
    }
    
    
    func test_getAccountDetails_when_request_does_not_contain_data() {
        // GIVEN that the account details request returns no data
        fixture.stubNoDataOnAccountDetailsResponse()
        instantiateSut()
        
        let expectation = expectation(description: "Account Details request is executed")
        var capturedError: NetworkRequestError?
        var capturedAccountDetails: AccountInfo?
        
        // WHEN getting the account details
        sut() { result in
            switch result {
            case .success(let accountInfo):
                capturedAccountDetails = accountInfo
            case .failure(let error):
                capturedError = error
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the account details request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.accountDetails)
        
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .connectionError(statusCode: 200, message: "No data found in the response"))
        
        // AND the Account info is NOT returned
        XCTAssertNil(capturedAccountDetails)
        
    }
    
    
    func test_getAccountDetails_when_refresh_tokens_fails() {
        // GIVEN that refreshing the Auth tokens fails
        fixture.stubErrorRefreshingAuthTokens()
        instantiateSut()
        
        let expectation = expectation(description: "Account Details request is executed")
        var capturedError: NetworkRequestError?
        var capturedAccountDetails: AccountInfo?
        
        // WHEN getting the account details
        sut() { result in
            switch result {
            case .success(let accountInfo):
                capturedAccountDetails = accountInfo
            case .failure(let error):
                capturedError = error
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the auth tokens checker is called to refresh the tokens
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND the account details request is NOT executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 0)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .allConnectionAttemptsFailed(statusCode: 401))
        
        // AND the Account info is NOT returned
        XCTAssertNil(capturedAccountDetails)
        
    }
    
}
