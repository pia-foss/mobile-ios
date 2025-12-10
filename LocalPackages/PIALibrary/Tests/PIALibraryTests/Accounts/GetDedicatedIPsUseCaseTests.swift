//
//  GetDedicatedIPsUseCaseTests.swift
//  
//
//  Created by Said Rehouni on 20/6/24.
//

import XCTest
@testable import PIALibrary

final class GetDedicatedIPsUseCaseTests: XCTestCase {
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
    var sut: GetDedicatedIPsUseCase!
    var capturedResult: Result<[DedicatedIPInformation], NetworkRequestError>!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        capturedResult = nil
    }
    
    private func instantiateSut() {
        sut = GetDedicatedIPsUseCase(networkClient: fixture.networkClientMock,
                                     refreshAuthTokensChecker: fixture.refreshAuthTokensCheckerMock)
    }
    
    func test_getDedicatedIPs_completes_with_credentials_succesfully_when_response_is_valid() {
        // GIVEN Network client completes with no error and a valid response
        let data = """
        "HTTP/1.1 200 OK\r\nServer: nginx\r\nDate: Thu, 04 Jul 2024 10:41:12 GMT\r\nContent-Type: application/json;\r\n[{\"id\":\"uk\",\"dip_token\":\"gdfgdfgfdg\",\"dip_expire\":13123,\"groups\":[\"ovpntcp\",\"ovpnudp\",\"wg\",\"ikev2\"],\"ip\":\"111.11.11.11\",\"cn\":\"cn\",\"status\":\"active\"}]\r\n0\r\n\r\n"
        """.data(using: .utf8)
        
        fixture.stubRequestWithResponse(NetworkRequestResponseStub(data: data))
        instantiateSut()
        
        let expectation = expectation(description: "Waiting for get dedicated ips to finish")
        
        // WHEN get dedicated ips is executed
        sut(dipTokens: ["gdfgdfgfdg"]) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with allConnectionAttemptsFailed error
        wait(for: [expectation], timeout: 1.0)
        guard case .success(let servers) = capturedResult else {
            XCTFail("Expected success got failure")
            return
        }
        
        let sortedServers = servers.sorted { ($0.id ?? "") < ($1.id ?? "") }
        XCTAssertEqual(sortedServers[0].id, "uk")
        XCTAssertEqual(sortedServers[0].ip, "111.11.11.11")
        XCTAssertEqual(sortedServers[0].cn, "cn")
        XCTAssertEqual(sortedServers[0].groups, ["ovpntcp", "ovpnudp", "wg", "ikev2"])
        XCTAssertEqual(sortedServers[0].dipExpire, 13123)
        XCTAssertEqual(sortedServers[0].dipToken, "gdfgdfgfdg")
        XCTAssertEqual(sortedServers[0].status, .active)
    }
    
    func test_getDedicatedIPs_completes_with_a_allConnectionAttemptsFailed_error_when_there_is_no_error_and_no_response() {
        // GIVEN Network client completes with no error and no response
        instantiateSut()
        
        let expectation = expectation(description: "Waiting for get dedicated ips to finish")
        
        // WHEN get dedicated ips is executed
        sut(dipTokens: []) { [weak self] result in
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
    
    func test_getDedicatedIPs_completes_with_a_noDataContent_error_when_there_is_response_with_no_data() {
        // GIVEN Network client completes with a response with invalid data
        fixture.stubRequestWithResponse(NetworkRequestResponseStub(data: nil))
        instantiateSut()
        
        let expectation = expectation(description: "Waiting for get dedicated ips to finish")
        
        // WHEN get dedicated ips is executed
        sut(dipTokens: []) { [weak self] result in
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
    
    func test_getDedicatedIPs_completes_with_a_unableToDecodeDataContent_error_when_there_is_response_with_invalid_data() {
        // GIVEN Network client completes with a response with invalid data
        let data = "{ \"status\" : \"status\", \"user\" : \"username\", \"pass\" : \"password\"}"
            .data(using: .utf8)
        
        fixture.stubRequestWithResponse(NetworkRequestResponseStub(data: data))
        instantiateSut()
        
        let expectation = expectation(description: "Waiting for get dedicated ips to finish")
        
        // WHEN get dedicated ips is executed
        sut(dipTokens: []) { [weak self] result in
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
    
    func test_getDedicatedIPs_completes_with_an_unauthorized_error_when_there_is_401_status_code() {
        // GIVEN Network client completes with an 401 status code error
        instantiateSut()
        fixture.stubRequestWithError(.connectionError(statusCode: 401, message: "any message"))
        let expectation = expectation(description: "Waiting for get dedicated ips to finish")
        
        // WHEN get dedicated ips is executed
        sut(dipTokens: []) { [weak self] result in
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

    func test_getDedicatedIPs_creates_valid_networkConfiguration() {
        // GIVEN
        let expectedBody = try? JSONEncoder().encode(["tokens": ["001", "002"]])
        instantiateSut()
        
        // WHEN get dedicated ips is executed
        sut.callAsFunction(dipTokens: ["001", "002"]) { _ in }
        
        // THEN
        guard let capturedConfiguration = fixture.networkClientMock.executeRequestWithConfiguation as? GetDedicatedIPsRequestConfiguration else {
            XCTFail("Expected GetDedicatedIPsRequestConfiguration configuration")
            return
        }
        
        XCTAssertEqual(capturedConfiguration.networkRequestModule, .account)
        XCTAssertEqual(capturedConfiguration.path, .dedicatedIp)
        XCTAssertEqual(capturedConfiguration.httpMethod, .post)
        XCTAssertTrue(capturedConfiguration.inlcudeAuthHeaders)
        XCTAssertEqual(capturedConfiguration.contentType, .json)
        XCTAssertNil(capturedConfiguration.urlQueryParameters)
        XCTAssertEqual(capturedConfiguration.responseDataType, .rawData)
        XCTAssertEqual(capturedConfiguration.timeout, 10)
        XCTAssertEqual(capturedConfiguration.body?.count, expectedBody?.count)
    }
}
