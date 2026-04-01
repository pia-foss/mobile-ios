
import XCTest
@testable import PIALibrary

class FeatureFlagsUseCaseTests: XCTestCase {
    class Fixture {
        let networkClientMock = NetworkRequestClientMock()
        let refreshAuthTokensCheckerMock = RefreshAuthTokensCheckerMock()
        
        let validFeatureFlagsJsonString = "{\"flags\": [\"feature_one\", \"feature_two\"], \"other_key\":\"other_value\"}"
        
        var validFeatureFlagsJsonData: Data {
            validFeatureFlagsJsonString.data(using: .utf8)!
        }
        
        let invalidFeatureFlagsJsonString = "{\"invalid_flags\": [\"feature_one\", \"feature_two\"], \"other_key\":\"other_value\"}"
        
        var invalidFeatureFlagsJsonData: Data {
            invalidFeatureFlagsJsonString.data(using: .utf8)!
        }
        
        func stubFeatureFlagsSuccessfullResponse() {
            let successResponse = NetworkRequestResponseMock(statusCode: 200, data: validFeatureFlagsJsonData)
            networkClientMock.executeRequestResponse = successResponse
        }
        
        func stubFeatureFlagsResponseWithInvalidData() {
            let successResponse = NetworkRequestResponseMock(statusCode: 200, data: invalidFeatureFlagsJsonData)
            networkClientMock.executeRequestResponse = successResponse
        }
        
        func stubFeatureFlagsResponseWithError(_ error: NetworkRequestError) {
            networkClientMock.executeRequestError = error
        }
        
        func stubRefreshAuthTokensIfNeededWithError(_ error: NetworkRequestError?) {
            refreshAuthTokensCheckerMock.refreshIfNeededError = error
        }
        
        func stubFeatureFlagsResponseWithNoData() {
            networkClientMock.executeRequestResponse = NetworkRequestResponseMock(statusCode: 200, data: nil)
        }
        
        
    }
    
    var fixture: Fixture!
    var sut: FeatureFlagsUseCase!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = FeatureFlagsUseCase(networkClient: fixture.networkClientMock, refreshAuthTokensChecker: fixture.refreshAuthTokensCheckerMock)
    }
    
    func test_get_feature_flags_successfully() {
        // GIVEN that the request to get the feature flags succeeds
        fixture.stubFeatureFlagsSuccessfullResponse()
        
        instantiateSut()
        
        let expectation = expectation(description: "Get feature flags request is executed")
        
        var capturedError: NetworkRequestError?
        var capturedFlagsInfo: FeatureFlagsInformation?
        
        // WHEN executing the use case to get the feature flags
        sut() { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let featureFlagsInfo):
                capturedFlagsInfo = featureFlagsInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the feature flags request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.iosFeatureFlag)
        
        // AND the auth tokens are refreshed if needed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND the feature flags info is returned with "feature_one" and "feature_two" enabled
        XCTAssertNotNil(capturedFlagsInfo)
        XCTAssertTrue(capturedFlagsInfo!.flags.count == 2)
        XCTAssertTrue(capturedFlagsInfo!.flags.contains("feature_one"))
        XCTAssertTrue(capturedFlagsInfo!.flags.contains("feature_two"))
        
        // AND no error is returned
        XCTAssertNil(capturedError)
        
    }
    
    func test_get_feature_flags_when_network_error() {
        // GIVEN that the request to get the feature flags fails
        fixture.stubFeatureFlagsResponseWithError(.allConnectionAttemptsFailed(statusCode: 401))
        
        instantiateSut()
        
        let expectation = expectation(description: "Get feature flags request is executed")
        
        var capturedError: NetworkRequestError?
        var capturedFlagsInfo: FeatureFlagsInformation?
        
        // WHEN executing the use case to get the feature flags
        sut() { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let featureFlagsInfo):
                capturedFlagsInfo = featureFlagsInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the feature flags request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.iosFeatureFlag)
        
        // AND the auth tokens are refreshed if needed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND no feature flags are returned
        XCTAssertNil(capturedFlagsInfo)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        
        XCTAssertEqual(capturedError, .allConnectionAttemptsFailed(statusCode: 401))
        
    }
    
    func test_get_feature_flags_when_no_data_on_the_response() {
        // GIVEN that the request to get the feature flags returns  no data in the response
        fixture.stubFeatureFlagsResponseWithNoData()
        
        instantiateSut()
        
        let expectation = expectation(description: "Get feature flags request is executed")
        
        var capturedError: NetworkRequestError?
        var capturedFlagsInfo: FeatureFlagsInformation?
        
        // WHEN executing the use case to get the feature flags
        sut() { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let featureFlagsInfo):
                capturedFlagsInfo = featureFlagsInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the feature flags request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.iosFeatureFlag)
        
        // AND the auth tokens are refreshed if needed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND no feature flags are returned
        XCTAssertNil(capturedFlagsInfo)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        
        XCTAssertEqual(capturedError, .noDataContent)
        
    }
    
    func test_get_feature_flags_when_invalid_data_on_the_response() {
        // GIVEN that the request to get the feature flags returns invalid data in the response
        fixture.stubFeatureFlagsResponseWithInvalidData()
        
        instantiateSut()
        
        let expectation = expectation(description: "Get feature flags request is executed")
        
        var capturedError: NetworkRequestError?
        var capturedFlagsInfo: FeatureFlagsInformation?
        
        // WHEN executing the use case to get the feature flags
        sut() { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let featureFlagsInfo):
                capturedFlagsInfo = featureFlagsInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the feature flags request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.iosFeatureFlag)
        
        // AND the auth tokens are refreshed if needed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND no feature flags are returned
        XCTAssertNil(capturedFlagsInfo)
        
        // AND an error is returned
        XCTAssertNotNil(capturedError)
        
        XCTAssertEqual(capturedError, .unableToDecodeData)
        
    }
    
    func test_get_feature_flags_when_refresh_tokens_error() {
        // GIVEN that the request to refresh the auth tokens fails
        fixture.stubRefreshAuthTokensIfNeededWithError(.allConnectionAttemptsFailed(statusCode: 401))
        // AND GIVEN that the request to get the feature flags succeeds
        fixture.stubFeatureFlagsSuccessfullResponse()
        
        instantiateSut()
        
        let expectation = expectation(description: "Get feature flags request is executed")
        
        var capturedError: NetworkRequestError?
        var capturedFlagsInfo: FeatureFlagsInformation?
        
        // WHEN executing the use case to get the feature flags
        sut() { result in
            switch result {
            case .failure(let error):
                capturedError = error
            case .success(let featureFlagsInfo):
                capturedFlagsInfo = featureFlagsInfo
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the feature flags request is executed
        XCTAssertEqual(fixture.networkClientMock.executeRequestCalledAttempt, 1)
        XCTAssertEqual(fixture.networkClientMock.executeRequestWithConfiguation?.path, RequestAPI.Path.iosFeatureFlag)
        
        // AND call to refresh the auth tokens if needed is executed
        XCTAssertEqual(fixture.refreshAuthTokensCheckerMock.refreshIfNeededCalledAttempt, 1)
        
        // AND the feature flags info is returned with "feature_one" and "feature_two" enabled
        XCTAssertNotNil(capturedFlagsInfo)
        XCTAssertTrue(capturedFlagsInfo!.flags.count == 2)
        XCTAssertTrue(capturedFlagsInfo!.flags.contains("feature_one"))
        XCTAssertTrue(capturedFlagsInfo!.flags.contains("feature_two"))
        
        // AND no error is returned
        XCTAssertNil(capturedError)
    }
    
}
