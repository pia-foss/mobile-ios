import XCTest

@testable import PIALibrary

class LoginUseCaseTests: XCTestCase {
    class Fixture {
        let networkClientMock = NetworkRequestClientMock()
        let apiTokenProviderMock = APITokenProviderMock()
        let refreshVpnTokenUseCaseMock = RefreshVpnTokenUseCaseMock()
        let validApiTokenJsonString = "{\"api_token\":\"some_api_token\",\"expires_at\":\"2034-08-11T00:00:00Z\"}"

        var validApiTokenJsonData: Data!
        let userEmail = "user@email.com"
        var userEmailData: Data {
            let dict = ["email": userEmail]
            return try! JSONEncoder().encode(dict)
        }

        init() {
            validApiTokenJsonData = validApiTokenJsonString.data(using: .utf8)
        }

        let credentials = Credentials(username: "username", password: "password")

        var credentialsBodyData: Data {
            return try! JSONEncoder().encode(credentials)
        }

        let receiptData = Data()
        var receiptBodyData: Data {
            let receiptRequestDict = [
                "store": "apple_app_store",
                "receipt": receiptData.base64EncodedString()
            ]

            return try! JSONEncoder().encode(receiptRequestDict)
        }

        func stubLoginSuccessfulResponse() {
            let successResponse = NetworkRequestResponseMock(statusCode: 200, data: validApiTokenJsonData)

            networkClientMock.executeRequestResponse = successResponse
        }

        /// A non-success status code never reaches the use case as a response: `NetworkRequestClient`
        /// turns it into an error through `tryNextConnectionOrFail`
        func stubLoginFailedResponseWith401() {
            networkClientMock.executeRequestError = .allConnectionAttemptsFailed(statusCode: 401)
        }

        func stubLoginFailedResponseWithError() {
            networkClientMock.executeRequestError = .connectionError(statusCode: 500)
        }

        func stubLoginSuccessfulResponseWithNoData() {
            networkClientMock.executeRequestResponse = NetworkRequestResponseMock(statusCode: 200)
        }

        func stubFailSavingApiToken() {
            apiTokenProviderMock.saveAPITokenFromDataError = NetworkRequestError.unableToSaveAPIToken
        }

        func stubFailDecodingApiToken() {
            apiTokenProviderMock.saveAPITokenFromDataError = NetworkRequestError.unableToDecodeAPIToken
        }

        func stubFailRefreshingVpnToken() {
            refreshVpnTokenUseCaseMock.completionError = .connectionError(statusCode: 500)
        }

        func stubFailRefreshingVpnTokenAsUnauthorized() {
            refreshVpnTokenUseCaseMock.completionError = .allConnectionAttemptsFailed(statusCode: 401)
        }

        func stubFailRefreshingVpnTokenAsThrottled() {
            refreshVpnTokenUseCaseMock.completionError = .allConnectionAttemptsFailed(statusCode: 429)
        }

        func stubLoginLinkSuccessfulResponse() {
            let successResponse = NetworkRequestResponseMock(statusCode: 200)

            networkClientMock.executeRequestResponse = successResponse
        }

    }

    var fixture: Fixture!
    var sut: LoginUseCase!

    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }

    private func instantiateSut() {
        sut = LoginUseCase(networkClient: fixture.networkClientMock, apiTokenProvider: fixture.apiTokenProviderMock, refreshVpnTokenUseCase: fixture.refreshVpnTokenUseCaseMock)
    }

    func testLoginWithCredentialsWhenRequestSucceeds() {
        // GIVEN that the network request to login with creds succeeds
        fixture.stubLoginSuccessfulResponse()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with Creds
        sut.login(with: fixture.credentials) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the login request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.login)

        // WITH the username and password encoded in the body of the request
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.body?.count, fixture.credentialsBodyData.count)

        // AND the API token from the response is stored
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledAttempt, 1)
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledWithArg, fixture.validApiTokenJsonData)

        // AND the Vpn token is refreshed after login
        XCTAssertEqual(fixture.refreshVpnTokenUseCaseMock.callAsFunctionCalledAttempt, 1)

        // AND no error is returned
        XCTAssertNil(capturedError)

    }

    func testLoginWithCredentialsWhenResponseFailsWith401() {
        // GIVEN that the network request to login with creds fails with status code 401
        fixture.stubLoginFailedResponseWith401()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with Creds
        sut.login(with: fixture.credentials) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the login request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.login)

        // AND the API token provider is NOT called to save anything
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledAttempt, 0)

        // AND the Vpn token is NOT refreshed
        XCTAssertEqual(fixture.refreshVpnTokenUseCaseMock.callAsFunctionCalledAttempt, 0)

        // AND the actual 401 error is returned, which ClientErrorMapper maps to 'unauthorized'
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .allConnectionAttemptsFailed(statusCode: 401))
        XCTAssertEqual(capturedError!.asClientError(), .unauthorized)

    }

    func testLoginWithCredentialsWhenResponseFailsWithServerError() {
        // GIVEN that the network request to login with creds fails with server error
        fixture.stubLoginFailedResponseWithError()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with Creds
        sut.login(with: fixture.credentials) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the login request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.login)

        // AND the API token provider is NOT called to save anything
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledAttempt, 0)

        // AND the Vpn token is NOT refreshed
        XCTAssertEqual(fixture.refreshVpnTokenUseCaseMock.callAsFunctionCalledAttempt, 0)

        // AND the actual connection error is returned (not 'unauthorized')
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .connectionError(statusCode: 500))

    }

    func testLoginWithReceiptWhenRequestSucceeds() {
        // GIVEN that the network request to login with receipt succeeds
        fixture.stubLoginSuccessfulResponse()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with receipt
        sut.login(with: fixture.receiptData) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the login request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.login)

        // WITH the receipt encoded in the body of the request
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.body?.count, fixture.receiptBodyData.count)

        // AND the API token from the response is stored
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledAttempt, 1)
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledWithArg, fixture.validApiTokenJsonData)

        // AND the Vpn token is refreshed after login
        XCTAssertEqual(fixture.refreshVpnTokenUseCaseMock.callAsFunctionCalledAttempt, 1)

        // AND no error is returned
        XCTAssertNil(capturedError)

    }

    func testLoginWithReceiptWhenResponseFailsWith401() {
        // GIVEN that the network request to login with receipt fails with status code 401
        fixture.stubLoginFailedResponseWith401()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with Receipt
        sut.login(with: fixture.receiptData) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the login request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.login)

        // AND the API token provider is NOT called to save anything
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledAttempt, 0)
        // AND the Vpn token is NOT refreshed
        XCTAssertEqual(fixture.refreshVpnTokenUseCaseMock.callAsFunctionCalledAttempt, 0)

        // AND the actual 401 error is returned, which ClientErrorMapper maps to 'unauthorized'
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .allConnectionAttemptsFailed(statusCode: 401))
        XCTAssertEqual(capturedError!.asClientError(), .unauthorized)

    }

    func testLoginWithReceiptWhenResponseFailsWithServerError() {
        // GIVEN that the network request to login with receipt fails with server error
        fixture.stubLoginFailedResponseWithError()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with Creds
        sut.login(with: fixture.receiptData) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the login request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.login)

        // AND the API token provider is NOT called to save anything
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledAttempt, 0)
        // AND the Vpn token is NOT refreshed
        XCTAssertEqual(fixture.refreshVpnTokenUseCaseMock.callAsFunctionCalledAttempt, 0)

        // AND the actual connection error is returned (not 'unauthorized')
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .connectionError(statusCode: 500))

    }

    func testLoginLinkWhenRequestSucceeds() {
        // GIVEN that the network request to login link succeeds
        fixture.stubLoginLinkSuccessfulResponse()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login link with email
        sut.loginLink(with: fixture.userEmail) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the login link request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.loginLink)

        // WITH the email encoded in the body of the request
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.body?.count, fixture.userEmailData.count)

        // AND the API token provider is not called to store anything
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledAttempt, 0)

        // AND no error is returned
        XCTAssertNil(capturedError)

    }

    func testLoginLinkWhenResponseFails() {
        // GIVEN that the network request to login link fails
        fixture.stubLoginFailedResponseWithError()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login link with email
        sut.loginLink(with: fixture.userEmail) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the login link request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.loginLink)

        // AND the actual connection error is returned (not 'unauthorized')
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .connectionError(statusCode: 500))

    }

    func testLoginWithCredentialsWhenResponseHasNoData() {
        // GIVEN that the network request to login with creds succeeds but carries no data
        fixture.stubLoginSuccessfulResponseWithNoData()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with Creds
        sut.login(with: fixture.credentials) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the API token provider is NOT called to save anything
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledAttempt, 0)

        // AND the Vpn token is NOT refreshed
        XCTAssertEqual(fixture.refreshVpnTokenUseCaseMock.callAsFunctionCalledAttempt, 0)

        // AND a malformed response error is returned (not 'unauthorized')
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .noDataContent)
        XCTAssertEqual(capturedError!.asClientError(), .malformedResponseData)

    }

    func testLoginWithCredentialsWhenDecodingTheApiTokenFails() {
        // GIVEN that the login succeeds but the API token in the response cannot be decoded
        fixture.stubLoginSuccessfulResponse()
        fixture.stubFailDecodingApiToken()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with Creds
        sut.login(with: fixture.credentials) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN saving the API token was attempted
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledAttempt, 1)

        // AND the Vpn token is NOT refreshed
        XCTAssertEqual(fixture.refreshVpnTokenUseCaseMock.callAsFunctionCalledAttempt, 0)

        // AND the decoding error is propagated (not 'unauthorized')
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .unableToDecodeAPIToken)
        XCTAssertEqual(capturedError!.asClientError(), .malformedResponseData)

    }

    func testLoginWithCredentialsWhenSavingTheApiTokenFails() {
        // GIVEN that the login succeeds but the API token cannot be saved
        fixture.stubLoginSuccessfulResponse()
        fixture.stubFailSavingApiToken()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with Creds
        sut.login(with: fixture.credentials) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN saving the API token was attempted
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledAttempt, 1)

        // AND the Vpn token is NOT refreshed
        XCTAssertEqual(fixture.refreshVpnTokenUseCaseMock.callAsFunctionCalledAttempt, 0)

        // AND the save error is returned (not 'unauthorized')
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .unableToSaveAPIToken)
        XCTAssertEqual(capturedError!.asClientError(), .unexpectedReply)

    }

    func testLoginWithCredentialsWhenRefreshingTheVpnTokenFails() {
        // GIVEN that the login succeeds but refreshing the Vpn token afterwards fails
        fixture.stubLoginSuccessfulResponse()
        fixture.stubFailRefreshingVpnToken()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with Creds
        sut.login(with: fixture.credentials) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the API token from the response was already stored successfully,
        // so the credentials were valid
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledAttempt, 1)
        XCTAssertEqual(fixture.apiTokenProviderMock.saveAPITokenFromDataCalledWithArg, fixture.validApiTokenJsonData)

        // AND the Vpn token refresh was attempted
        XCTAssertEqual(fixture.refreshVpnTokenUseCaseMock.callAsFunctionCalledAttempt, 1)

        // AND the actual refresh error is returned (not 'unauthorized')
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .connectionError(statusCode: 500))
        XCTAssertEqual(capturedError!.asClientError(), .unexpectedReply)

    }

    func testLoginWithCredentialsWhenRefreshingTheVpnTokenIsThrottled() {
        // GIVEN that the login succeeds but refreshing the Vpn token fails with status code 429
        fixture.stubLoginSuccessfulResponse()
        fixture.stubFailRefreshingVpnTokenAsThrottled()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with Creds
        sut.login(with: fixture.credentials) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the throttling information is preserved, so the retry delay can be shown
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .allConnectionAttemptsFailed(statusCode: 429))
        XCTAssertEqual(capturedError!.asClientError(), .throttled(retryAfter: 60))

    }

    func testLoginWithCredentialsWhenRefreshingTheVpnTokenIsUnauthorized() {
        // GIVEN that the login succeeds but refreshing the Vpn token fails with status code 401
        fixture.stubLoginSuccessfulResponse()
        fixture.stubFailRefreshingVpnTokenAsUnauthorized()

        instantiateSut()

        let expectation = expectation(description: "Login call is finished")
        var capturedError: NetworkRequestError? = nil

        // WHEN login with Creds
        sut.login(with: fixture.credentials) { error in
            capturedError = error
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)

        // THEN the Vpn token refresh was attempted
        XCTAssertEqual(fixture.refreshVpnTokenUseCaseMock.callAsFunctionCalledAttempt, 1)

        // AND the genuine auth failure is preserved rather than reported as a Vpn token error
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .allConnectionAttemptsFailed(statusCode: 401))
        XCTAssertEqual(capturedError!.asClientError(), .unauthorized)

    }

}
