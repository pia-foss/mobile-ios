
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
            let credsDict = credentials.toJSONDictionary() as! [String: String]
            
            return try! JSONEncoder().encode(credsDict)
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
        
        func stubLoginFailedResponseWith401() {
            let response = NetworkRequestResponseMock(statusCode: 401)
            networkClientMock.executeRequestResponse = response
        }
        
        func stubLoginFailedResponseWithError() {
            networkClientMock.executeRequestError = .connectionError(statusCode: 500)
        }
        
        func stubFailSavingApiToken() {
            apiTokenProviderMock.saveAPITokenFromDataError = NetworkRequestError.unableToSaveAPIToken
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
        
        // AND an 'unauthorized' error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .unauthorized)
        
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
        
        // AND an 'unauthorized' error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .unauthorized)
        
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
        
        // AND an 'unauthorized' error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .unauthorized)
        
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
        
        // AND an 'unauthorized' error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .unauthorized)
        
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
        
        // AND an 'unauthorized' error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError!, .unauthorized)
        
    }
    
    
}
