
import XCTest
@testable import PIALibrary

class UpdateAccountUseCaseTests: XCTestCase {
    class Fixture {
        let networkClientMock = NetworkRequestClientMock()
        let refreshAuthTokenCheckerMock = RefreshAuthTokensCheckerMock()
        let tempPassword = "TempPass123"
        
        func stubRefreshAuthTokenWithError(error: NetworkRequestError) {
            refreshAuthTokenCheckerMock.refreshIfNeededError = error
        }
        
        func stubUpdateAccountSuccessfulResponseWith(temporaryPassword: Bool) {
            var successResponseDict = ["status": "success"]
            
            if temporaryPassword {
                successResponseDict["password"] = tempPassword
            }
            
            let successResponseDictData = try! JSONEncoder().encode(successResponseDict)
            let successfulResponse = NetworkRequestResponseMock(statusCode: 200, data: successResponseDictData)
            
            networkClientMock.executeRequestResponse = successfulResponse
        }
        
        func stubUpdateAccountResponseWithNoData() {
            let successfulResponse = NetworkRequestResponseMock(statusCode: 200, data: nil)
            
            networkClientMock.executeRequestResponse = successfulResponse
        }
        
        
        func stubUpdateAccountWithError(error: NetworkRequestError) {
            networkClientMock.executeRequestError = error
        }
    }
    
    var fixture: Fixture!
    var sut: UpdateAccountUseCase!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = UpdateAccountUseCase(networkClient: fixture.networkClientMock, refreshAuthTokensChecker: fixture.refreshAuthTokenCheckerMock)
    }
    
    func test_updateAccountWithoutResetPassword_when_response_is_successful() {
        // GIVEN that update account without reseting password succeeds
        fixture.stubUpdateAccountSuccessfulResponseWith(temporaryPassword: false)
        instantiateSut()
        
        let expectation = expectation(description: "Update account request executed")
        var capturedError: NetworkRequestError?
        var capturedNewPassword: String?
        
        // WHEN updating the account
        sut.setEmail(username: "user", password: "pass", email: "email@mail.com", resetPassword: false) { result in
            
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let newPassword):
                capturedNewPassword = newPassword
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the auth tokens are refeshed if needed
        XCTAssertEqual(fixture.refreshAuthTokenCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // AND the `setEmail` request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.setEmail)
        // WITH the correct url query parameters
        XCTAssertEqual(executedRequestConfiguration.urlQueryParameters, ["email": "email@mail.com", "reset_password": "false"])
        
        let userPassToBase64 = "user:pass".toBase64()!
        let otherHeaders = ["Authorization": "Basic \(userPassToBase64)"]
        
        // AND the Basic Authorization Header
        XCTAssertEqual(executedRequestConfiguration.otherHeaders!, otherHeaders)
        
        // AND no error is returned
        XCTAssertNil(capturedError)
        
        // AND no new password is returned
        XCTAssertNil(capturedNewPassword)
        
    }
    
    
    func test_updateAccountWithoutResetPassword_when_request_returns_error() {
        // GIVEN that update account without reseting password returns an error
        fixture.stubUpdateAccountWithError(error: .allConnectionAttemptsFailed(statusCode: 401))
        
        instantiateSut()
        
        let expectation = expectation(description: "Update account request executed")
        var capturedError: NetworkRequestError?
        var capturedNewPassword: String?
        
        // WHEN updating the account
        sut.setEmail(username: "user", password: "pass", email: "email@mail.com", resetPassword: false) { result in
            
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let newPassword):
                capturedNewPassword = newPassword
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the auth tokens are refeshed if needed
        XCTAssertEqual(fixture.refreshAuthTokenCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // AND the `setEmail` request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.setEmail)
        // WITH the correct url query parameters
        XCTAssertEqual(executedRequestConfiguration.urlQueryParameters, ["email": "email@mail.com", "reset_password": "false"])
        
        let userPassToBase64 = "user:pass".toBase64()!
        let otherHeaders = ["Authorization": "Basic \(userPassToBase64)"]
        
        // AND the Basic Authorization Header
        XCTAssertEqual(executedRequestConfiguration.otherHeaders!, otherHeaders)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .allConnectionAttemptsFailed(statusCode: 401))
        
        // AND no new password is returned
        XCTAssertNil(capturedNewPassword)
        
    }
    
    func test_updateAccountWithoutResetPassword_when_refreshingTokensFail() {
        // GIVEN that refreshing tokens fail
        fixture.stubRefreshAuthTokenWithError(error: .allConnectionAttemptsFailed(statusCode: 401))
        
        instantiateSut()
        
        let expectation = expectation(description: "Update account request executed")
        var capturedError: NetworkRequestError?
        var capturedNewPassword: String?
        
        // WHEN updating the account
        sut.setEmail(username: "user", password: "pass", email: "email@mail.com", resetPassword: false) { result in
            
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let newPassword):
                capturedNewPassword = newPassword
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the auth tokens request is executed
        XCTAssertEqual(fixture.refreshAuthTokenCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation
        
        // AND the `setEmail` request is NOT executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 0)
        XCTAssertNil(executedRequestConfiguration)
       
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .allConnectionAttemptsFailed(statusCode: 401))
        
        // AND no new password is returned
        XCTAssertNil(capturedNewPassword)
        
    }
    
    func test_updateAccountWithoutResetPassword_when_request_returns_noData() {
        // GIVEN that update account without reseting password returns no data
        fixture.stubUpdateAccountResponseWithNoData()
        
        instantiateSut()
        
        let expectation = expectation(description: "Update account request executed")
        var capturedError: NetworkRequestError?
        var capturedNewPassword: String?
        
        // WHEN updating the account
        sut.setEmail(username: "user", password: "pass", email: "email@mail.com", resetPassword: false) { result in
            
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let newPassword):
                capturedNewPassword = newPassword
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the auth tokens are refeshed if needed
        XCTAssertEqual(fixture.refreshAuthTokenCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // AND the `setEmail` request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.setEmail)
        // WITH the correct url query parameters
        XCTAssertEqual(executedRequestConfiguration.urlQueryParameters, ["email": "email@mail.com", "reset_password": "false"])
        
        let userPassToBase64 = "user:pass".toBase64()!
        let otherHeaders = ["Authorization": "Basic \(userPassToBase64)"]
        
        // AND the Basic Authorization Header
        XCTAssertEqual(executedRequestConfiguration.otherHeaders!, otherHeaders)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .noDataContent)
        
        // AND no new password is returned
        XCTAssertNil(capturedNewPassword)
        
    }
    
    func test_updateAccountWithResetPassword_when_response_is_successful() {
        // GIVEN that update account with reseting password succeeds
        fixture.stubUpdateAccountSuccessfulResponseWith(temporaryPassword: true)
        instantiateSut()
        
        let expectation = expectation(description: "Update account request executed")
        var capturedError: NetworkRequestError?
        var capturedNewPassword: String?
        
        // WHEN updating the account with reset password
        sut.setEmail(email: "email@mail.com", resetPassword: true) { result in
            
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let newPassword):
                capturedNewPassword = newPassword
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the auth tokens are refeshed if needed
        XCTAssertEqual(fixture.refreshAuthTokenCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // AND the `setEmail` request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.setEmail)
        // WITH the correct body Data
        let submittedBody = ["email": "email@mail.com", "reset_password": "true"]
        let submittedBodyData = try! JSONEncoder().encode(submittedBody)
        XCTAssertEqual(executedRequestConfiguration.body!.count, submittedBodyData.count)
        // AND the Token Authorization Header
        XCTAssertTrue(executedRequestConfiguration.inlcudeAuthHeaders)
        
        // AND no error is returned
        XCTAssertNil(capturedError)
        
        // AND a new password is returned
        XCTAssertEqual(capturedNewPassword, fixture.tempPassword)
        
    }
    
    
    func test_updateAccountWithResetPassword_when_request_returns_error() {
        // GIVEN that update account without reseting password returns an error
        fixture.stubUpdateAccountWithError(error: .allConnectionAttemptsFailed(statusCode: 401))
        
        instantiateSut()
        
        let expectation = expectation(description: "Update account request executed")
        var capturedError: NetworkRequestError?
        var capturedNewPassword: String?
        
        // WHEN updating the account with reset password
        sut.setEmail(email: "email@mail.com", resetPassword: true) { result in
            
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let newPassword):
                capturedNewPassword = newPassword
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the auth tokens are refeshed if needed
        XCTAssertEqual(fixture.refreshAuthTokenCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // AND the `setEmail` request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.setEmail)
        // WITH the correct body Data
        let submittedBody = ["email": "email@mail.com", "reset_password": "true"]
        let submittedBodyData = try! JSONEncoder().encode(submittedBody)
        XCTAssertEqual(executedRequestConfiguration.body!.count, submittedBodyData.count)
        
        // AND the Token Authorization Header
        XCTAssertTrue(executedRequestConfiguration.inlcudeAuthHeaders)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .allConnectionAttemptsFailed(statusCode: 401))
        
        // AND no new password is returned
        XCTAssertNil(capturedNewPassword)
        
    }
    
    func test_updateAccountWithResetPassword_when_refreshingTokensFail() {
        // GIVEN that refreshing tokens fail
        fixture.stubRefreshAuthTokenWithError(error: .allConnectionAttemptsFailed(statusCode: 401))
        
        instantiateSut()
        
        let expectation = expectation(description: "Update account request executed")
        var capturedError: NetworkRequestError?
        var capturedNewPassword: String?
        
        // WHEN updating the account with reset password
        sut.setEmail(email: "email@mail.com", resetPassword: true) { result in
            
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let newPassword):
                capturedNewPassword = newPassword
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the auth tokens request is executed
        XCTAssertEqual(fixture.refreshAuthTokenCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation
        
        // AND the `setEmail` request is NOT executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 0)
        XCTAssertNil(executedRequestConfiguration)
       
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .allConnectionAttemptsFailed(statusCode: 401))
        
        // AND no new password is returned
        XCTAssertNil(capturedNewPassword)
        
    }
    
}
