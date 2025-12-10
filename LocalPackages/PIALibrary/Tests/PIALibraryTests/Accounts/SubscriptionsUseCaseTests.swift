
import XCTest
@testable import PIALibrary

class SubscriptionsUseCaseTests: XCTestCase {
    class Fixture {
        let networkClientMock = NetworkRequestClientMock()
        let refreshAuthTokensCheckerMock = RefreshAuthTokensCheckerMock()
        let appStoreInformation = AppStoreInformation(
            products: [
                Product(identifier: "id1", plan: .monthly, price: "10", legacy: true),
                Product(identifier: "id2", plan: .yearly, price: "100", legacy: true)
            ],
            eligibleForTrial: true
        )
        
        let receiptBase64 = Data().base64EncodedString()
        
        var encodedAppStoreInformationData: Data {
            try! JSONEncoder().encode(appStoreInformation)
        }
        
        func stubSuccessfulRequestResponse() {
            networkClientMock.executeRequestResponse = NetworkRequestResponseMock(statusCode: 200, data: encodedAppStoreInformationData)
            networkClientMock.executeRequestError = nil
        }
        
        func stubRequestResponseWithNoData() {
            networkClientMock.executeRequestResponse = NetworkRequestResponseMock(statusCode: 200, data: nil)
        }

        func stubRequestResponseWithInvalidAppStoreInfoData() {
            networkClientMock.executeRequestResponse = NetworkRequestResponseMock(statusCode: 200, data: Data())
        }
        
        func stubNetworkRequestError(_ error: NetworkRequestError) {
            networkClientMock.executeRequestError = error
        }
        
        func stubRefreshAuthTokensError(_ error: NetworkRequestError) {
            refreshAuthTokensCheckerMock.refreshIfNeededError = error
        }
        
        
    }
    
    var fixture: Fixture!
    var sut: SubscriptionsUseCase!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = SubscriptionsUseCase(networkClient: fixture.networkClientMock, refreshAuthTokensChecker: fixture.refreshAuthTokensCheckerMock)
    }
    
    func test_getSubscriptions_withoutReceipt_when_network_request_succeeds() {
        // GIVEN that the network request succeeds
        fixture.stubSuccessfulRequestResponse()
        
        instantiateSut()
        
        let expectation = expectation(description: "Subscriptions request is executed")
        var capturedError: NetworkRequestError?
        var capturedAppStoreInformation: AppStoreInformation?
        
        // WHEN executing the subscription request without receipt
        sut.callAsFunction(receiptBase64: nil) { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let appStoreInfo):
                capturedAppStoreInformation = appStoreInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the refresh tokens if needed request is executed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // AND the subscriptions request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.iosSubscriptions)
        
        // WITH only the 'type' in the query parameters
        XCTAssertEqual(executedRequestConfiguration.urlQueryParameters!, ["type": "subscription"])
        
        // AND no error is returned
        XCTAssertNil(capturedError)
        
        // AND the AppStoreInformation is returned with 2 products
        XCTAssertEqual(capturedAppStoreInformation!.products.count, 2)
        // AND eligible for free trial
        XCTAssertTrue(capturedAppStoreInformation!.eligibleForTrial)
        
    }
    
    func test_getSubscriptions_withReceipt_when_network_request_succeeds() {
        // GIVEN that the network request succeeds
        fixture.stubSuccessfulRequestResponse()
        
        instantiateSut()
        
        let expectation = expectation(description: "Subscriptions request is executed")
        var capturedError: NetworkRequestError?
        var capturedAppStoreInformation: AppStoreInformation?
        
        // WHEN executing the subscription request with receipt
        sut.callAsFunction(receiptBase64: fixture.receiptBase64) { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let appStoreInfo):
                capturedAppStoreInformation = appStoreInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the refresh tokens if needed request is executed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // AND the subscriptions request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.iosSubscriptions)
        
        // WITH 'type' and 'receipt' in the query parameters
        XCTAssertEqual(executedRequestConfiguration.urlQueryParameters!, ["type": "subscription", "receipt": fixture.receiptBase64])
        
        // AND no error is returned
        XCTAssertNil(capturedError)
        
        // AND the AppStoreInformation is returned with 2 products
        XCTAssertEqual(capturedAppStoreInformation!.products.count, 2)
        // AND eligible for free trial
        XCTAssertTrue(capturedAppStoreInformation!.eligibleForTrial)
        
    }
    
    func test_getSubscriptions_when_network_request_fails() {
        // GIVEN that the network request fails
        fixture.stubNetworkRequestError(.allConnectionAttemptsFailed(statusCode: 401))
        
        instantiateSut()
        
        let expectation = expectation(description: "Subscriptions request is executed")
        var capturedError: NetworkRequestError?
        var capturedAppStoreInformation: AppStoreInformation?
        
        // WHEN executing the subscription request without receipt
        sut.callAsFunction(receiptBase64: nil) { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let appStoreInfo):
                capturedAppStoreInformation = appStoreInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the refresh tokens if needed request is executed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // AND the subscriptions request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.iosSubscriptions)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .allConnectionAttemptsFailed(statusCode: 401))
        
        // AND NO AppStoreInformation is returned
        XCTAssertNil(capturedAppStoreInformation)

    }
    
    func test_getSubscriptions_when_no_data_is_returned() {
        // GIVEN that the network request returns no data
        fixture.stubRequestResponseWithNoData()
        
        instantiateSut()
        
        let expectation = expectation(description: "Subscriptions request is executed")
        var capturedError: NetworkRequestError?
        var capturedAppStoreInformation: AppStoreInformation?
        
        // WHEN executing the subscription request without receipt
        sut.callAsFunction(receiptBase64: nil) { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let appStoreInfo):
                capturedAppStoreInformation = appStoreInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the refresh tokens if needed request is executed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // AND the subscriptions request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.iosSubscriptions)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .noDataContent)
        
        // AND NO AppStoreInformation is returned
        XCTAssertNil(capturedAppStoreInformation)

    }
    
    func test_getSubscriptions_when_invalid_data_is_returned() {
        // GIVEN that the network request returns invalid app store info data
        fixture.stubRequestResponseWithInvalidAppStoreInfoData()
        
        instantiateSut()
        
        let expectation = expectation(description: "Subscriptions request is executed")
        var capturedError: NetworkRequestError?
        var capturedAppStoreInformation: AppStoreInformation?
        
        // WHEN executing the subscription request without receipt
        sut.callAsFunction(receiptBase64: nil) { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let appStoreInfo):
                capturedAppStoreInformation = appStoreInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the refresh tokens if needed request is executed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // AND the subscriptions request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.iosSubscriptions)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        XCTAssertEqual(capturedError, .unableToDecodeData)
        
        // AND NO AppStoreInformation is returned
        XCTAssertNil(capturedAppStoreInformation)

    }
    
    func test_getSubscriptions_when_refreshAuthTokensFails() {
        // GIVEN that the network request succeeds
        fixture.stubSuccessfulRequestResponse()
        // AND GIVEN that refresh auth tokens request fails
        fixture.stubRefreshAuthTokensError(.allConnectionAttemptsFailed(statusCode: 401))
        
        instantiateSut()
        
        let expectation = expectation(description: "Subscriptions request is executed")
        var capturedError: NetworkRequestError?
        var capturedAppStoreInformation: AppStoreInformation?
        
        // WHEN executing the subscription request
        sut.callAsFunction(receiptBase64: nil) { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let appStoreInfo):
                capturedAppStoreInformation = appStoreInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the refresh tokens if needed request is executed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        let executedRequestConfiguration = fixture.networkClientMock.executeRequestWithConfiguation!
        
        // AND the subscriptions request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(executedRequestConfiguration.path, RequestAPI.Path.iosSubscriptions)
        
        // AND no error is returned
        XCTAssertNil(capturedError)
        
        // AND the AppStoreInformation is returned with 2 products
        XCTAssertEqual(capturedAppStoreInformation!.products.count, 2)
        // AND eligible for free trial
        XCTAssertTrue(capturedAppStoreInformation!.eligibleForTrial)
        
    }
    
}
