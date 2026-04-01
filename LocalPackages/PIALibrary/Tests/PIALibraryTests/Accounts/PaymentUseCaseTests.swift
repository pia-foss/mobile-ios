import XCTest
@testable import PIALibrary

class PaymentUseCaseTests: XCTestCase {
    class Fixture {
        let networkClientMock = NetworkRequestClientMock()
        let paymentInformationDataConverter = PaymentInformationDataConverter()
        let credentials = Credentials(username: "username", password: "password")
        let payment = Payment(receipt: Data())
        
        func stubSuccessFullNetworkRequest() {
            let successResponse = NetworkRequestResponseMock(statusCode: 200, data: Data())
            networkClientMock.executeRequestResponse = successResponse
            networkClientMock.executeRequestError = nil
        }
        
        func stubNetworRequestError(_ error: NetworkRequestError) {
            networkClientMock.executeRequestError = error
        }
    }
    
    var fixture: Fixture!
    var sut: PaymentUseCase!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = PaymentUseCase(networkClient: fixture.networkClientMock, paymentInformationDataConverter: fixture.paymentInformationDataConverter)
    }
   
    func test_payment_when_network_request_succeeds() {
        // GIVEN that the payment request succeeds
        fixture.stubSuccessFullNetworkRequest()
        
        instantiateSut()
        
        let expectation = expectation(description: "Payment request is executed")
        var capturedError: NetworkRequestError?
        
        // WHEN executing the request
        sut.callAsFunction(with: fixture.credentials, request: fixture.payment) { error in
            capturedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // THEN the payment request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.iosPayment)
        
        let userPassToBase64 = "username:password".toBase64()!
        let otherHeaders = ["Authorization": "Basic \(userPassToBase64)"]
        
        // WITH the Basic Authorization Header
        XCTAssertEqual(executedRequestConfiguration.otherHeaders!, otherHeaders)
        
        let requestBody = fixture.paymentInformationDataConverter(payment: fixture.payment)!
        
        // AND the payment info object encoded int he body
        XCTAssertEqual(executedRequestConfiguration.body!.count, requestBody.count)
        
        // AND no error is retured
        XCTAssertNil(capturedError)
        
    }
    
    func test_payment_when_network_request_failsWith401() {
        // GIVEN that the payment request fails
        fixture.stubNetworRequestError(.allConnectionAttemptsFailed(statusCode: 401))
        
        instantiateSut()
        
        let expectation = expectation(description: "Payment request is executed")
        var capturedError: NetworkRequestError?
        
        // WHEN executing the request
        sut.callAsFunction(with: fixture.credentials, request: fixture.payment) { error in
            capturedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // THEN the payment request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.iosPayment)
        
        let userPassToBase64 = "username:password".toBase64()!
        let otherHeaders = ["Authorization": "Basic \(userPassToBase64)"]
        
        // WITH the Basic Authorization Header
        XCTAssertEqual(executedRequestConfiguration.otherHeaders!, otherHeaders)
        
        let requestBody = fixture.paymentInformationDataConverter(payment: fixture.payment)!
        
        // AND the payment info object encoded int he body
        XCTAssertEqual(executedRequestConfiguration.body!.count, requestBody.count)
        
        // AND an Error is retured
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .allConnectionAttemptsFailed(statusCode: 401))
    }
    
    func test_payment_when_network_request_failsWith400() {
        // GIVEN that the payment request fails
        fixture.stubNetworRequestError(.allConnectionAttemptsFailed(statusCode: 400))
        
        instantiateSut()
        
        let expectation = expectation(description: "Payment request is executed")
        var capturedError: NetworkRequestError?
        
        // WHEN executing the request
        sut.callAsFunction(with: fixture.credentials, request: fixture.payment) { error in
            capturedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // THEN the payment request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.iosPayment)
        
        let userPassToBase64 = "username:password".toBase64()!
        let otherHeaders = ["Authorization": "Basic \(userPassToBase64)"]
        
        // WITH the Basic Authorization Header
        XCTAssertEqual(executedRequestConfiguration.otherHeaders!, otherHeaders)
        
        let requestBody = fixture.paymentInformationDataConverter(payment: fixture.payment)!
        
        // AND the payment info object encoded int he body
        XCTAssertEqual(executedRequestConfiguration.body!.count, requestBody.count)
        
        // AND an Error is retured
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .badReceipt)
    }
    
}
