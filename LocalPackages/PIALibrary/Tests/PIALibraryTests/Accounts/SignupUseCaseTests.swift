
import XCTest
@testable import PIALibrary

final class SignupUseCaseTests: XCTestCase {
    class Fixture {
        var networkClientMock = NetworkRequestClientMock()
        let signupInformationDataCoverter = SignupInformationDataCoverter()
        
        func stubRequestWithResponse(_ response: NetworkRequestResponseType) {
            networkClientMock.executeRequestResponse = response
        }
        
        func stubRequestWithError(_ error: NetworkRequestError) {
            networkClientMock.executeRequestError = error
        }
    }
    
    var fixture: Fixture!
    var sut: SignupUseCase!
    var capturedResult: Result<Credentials, NetworkRequestError>!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        capturedResult = nil
    }
    
    private func instantiateSut() {
        sut = SignupUseCase(networkClient: fixture.networkClientMock,
                            signupInformationDataCoverter: fixture.signupInformationDataCoverter)
    }
    
    func test_signup_completes_with_credentials_succesfully_when_response_is_valid() {
        // GIVEN Network client successfully completes with valid credentials
        let data = "{ \"status\" : \"status\", \"username\" : \"username\", \"password\" : \"password\"}"
            .data(using: .utf8)
        
        fixture.stubRequestWithResponse(NetworkRequestResponseStub(data: data))
        instantiateSut()
        
        let expectation = expectation(description: "Waiting for signup to complete")
        
        // WHEN signup is executed
        let signUpRequest = Signup(email: "email", receipt: Data())
        sut.callAsFunction(signup: signUpRequest) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with the expected valid credentials
        wait(for: [expectation], timeout: 1.0)
        guard case .success(let capturedCredentialsResult) = capturedResult else {
            XCTFail("Expected success, got failure")
            return
        }
        
        XCTAssertEqual(capturedCredentialsResult.username, "username")
        XCTAssertEqual(capturedCredentialsResult.password, "password")
    }
    
    func test_signup_completes_with_a_allConnectionAttemptsFailed_error_when_there_is_no_error_and_no_response() {
        // GIVEN Network client completes with no error and no response
        instantiateSut()
        
        let expectation = expectation(description: "Waiting for signup to complete")
        
        // WHEN signup is executed
        let signUpRequest = Signup(email: "email", receipt: Data())
        sut.callAsFunction(signup: signUpRequest) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with allConnectionAttemptsFailed error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure got success")
            return
        }
        
        XCTAssertEqual(error, .allConnectionAttemptsFailed())
    }
    
    func test_signup_completes_with_a_noDataContent_error_when_there_is_response_with_no_data() {
        // GIVEN Network client completes with a response with invalid data
        fixture.stubRequestWithResponse(NetworkRequestResponseStub(data: nil))
        instantiateSut()
        
        let expectation = expectation(description: "Waiting for signup to complete")
        
        // WHEN signup is executed
        let signUpRequest = Signup(email: "email", receipt: Data())
        sut.callAsFunction(signup: signUpRequest) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with allConnectionAttemptsFailed error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure got success")
            return
        }
        
        XCTAssertEqual(error, .noDataContent)
    }
    
    func test_signup_completes_with_a_unableToDecodeDataContent_error_when_there_is_response_with_invalid_data() {
        // GIVEN Network client completes with a response with invalid data
        let data = "{ \"status\" : \"status\", \"user\" : \"username\", \"pass\" : \"password\"}"
            .data(using: .utf8)
        
        fixture.stubRequestWithResponse(NetworkRequestResponseStub(data: data))
        instantiateSut()
        
        let expectation = expectation(description: "Waiting for signup to complete")
        
        // WHEN signup is executed
        let signUpRequest = Signup(email: "email", receipt: Data())
        sut.callAsFunction(signup: signUpRequest) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with allConnectionAttemptsFailed error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure got success")
            return
        }
        
        XCTAssertEqual(error, .unableToDecodeDataContent)
    }
    
    func test_signup_completes_with_a_badReceipt_error_when_there_is_a_400_status_code() {
        // GIVEN Network client completes with an connection error with 400 status code
        fixture.stubRequestWithError(.connectionError(statusCode: 400, message: ""))
        instantiateSut()
        
        let expectation = expectation(description: "Waiting for signup to complete")
        
        // WHEN signup is executed
        let signUpRequest = Signup(email: "email", receipt: Data())
        sut.callAsFunction(signup: signUpRequest) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with badReceipt error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Expected failure got success")
            return
        }
        
        XCTAssertEqual(error, .badReceipt)
    }
    
    func test_signup_creates_valid_networkConfiguration() {
        // GIVEN
        let expectedBody = SignupInformation(store: "apple_app_store", 
                                             receipt: Data().base64EncodedString(),
                                             email: "email",
                                             marketing: nil,
                                             debug: nil).toData()
        instantiateSut()
        
        // WHEN signup is executed
        let signUpRequest = Signup(email: "email", receipt: Data())
        sut.callAsFunction(signup: signUpRequest) { _ in }
        
        // THEN
        guard let capturedConfiguration = fixture.networkClientMock.executeRequestWithConfiguation as? SignupRequestConfiguration else {
            XCTFail("Expected SignupRequestConfiguration configuration")
            return
        }
        
        XCTAssertEqual(capturedConfiguration.networkRequestModule, .account)
        XCTAssertEqual(capturedConfiguration.path, .signup)
        XCTAssertEqual(capturedConfiguration.httpMethod, .post)
        XCTAssertFalse(capturedConfiguration.inlcudeAuthHeaders)
        XCTAssertFalse(capturedConfiguration.refreshAuthTokensIfNeeded)
        XCTAssertEqual(capturedConfiguration.contentType, .json)
        XCTAssertNil(capturedConfiguration.urlQueryParameters)
        XCTAssertEqual(capturedConfiguration.responseDataType, .jsonData)
        XCTAssertEqual(capturedConfiguration.timeout, 10)
        XCTAssertEqual(capturedConfiguration.body?.count, expectedBody?.count)
    }
}


