//
//  DedicatedIPProviderTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS
import PIALibrary

final class DedicatedIPProviderTests: XCTestCase {
    class Fixture {
        var dipServerProviderMock: DipServerProviderMock!
    }
    
    var fixture: Fixture!
    var sut: DedicatedIPProvider!
    
    func instantiateSut(server: Server?, error: Error?) {
        fixture.dipServerProviderMock = DipServerProviderMock(server: server, error: error)
        sut = DedicatedIPProvider(serverProvider: fixture.dipServerProviderMock)
    }
    
    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }

    func test_activateDIPToken_complets_successfully_when_DipServerProvider_complets_with_success() {
        // GIVEN
        let server = Server(serial: "", name: "", country: "", hostname: "", pingAddress: nil, dipStatus: .active, regionIdentifier: "")
        instantiateSut(server: server, error: nil)
        
        let expectation = expectation(description: "Waiting for activateDIPToken to complete")
        
        // WHEN
        sut.activateDIPToken("token") { result in
            switch result {
                case .success:
                    break
                default:
                    XCTFail("Expected failure, got success")
            }
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_activateDIPToken_fails_when_there_is_server_and_token_is_expired() {
        // GIVEN
        let server = Server(serial: "", name: "", country: "", hostname: "", pingAddress: nil, dipStatus: .expired, regionIdentifier: "")
        instantiateSut(server: server, error: nil)
        
        let expectation = expectation(description: "Waiting for activateDIPToken to complete")
        var capturedError: DedicatedIPError?
        
        // WHEN
        sut.activateDIPToken("token") { result in
            switch result {
                case let .failure(error):
                    capturedError = error
                default:
                    XCTFail("Expected failure, got success")
            }
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedError, .expired)
    }
    
    func test_activateDIPToken_fails_when_there_is_server_and_token_is_invalid() {
        // GIVEN
        let server = Server(serial: "", name: "", country: "", hostname: "", pingAddress: nil, dipStatus: .invalid, regionIdentifier: "")
        instantiateSut(server: server, error: nil)
        
        let expectation = expectation(description: "Waiting for activateDIPToken to complete")
        var capturedError: DedicatedIPError?
        
        // WHEN
        sut.activateDIPToken("token") { result in
            switch result {
                case let .failure(error):
                    capturedError = error
                default:
                    XCTFail("Expected failure, got success")
            }
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedError, .invalid)
    }
    
    func test_activateDIPToken_fails_when_there_is_server_and_status_is_error() {
        // GIVEN
        let server = Server(serial: "", name: "", country: "", hostname: "", pingAddress: nil, dipStatus: .error, regionIdentifier: "")
        instantiateSut(server: server, error: nil)
        
        let expectation = expectation(description: "Waiting for activateDIPToken to complete")
        var capturedError: DedicatedIPError?
        
        // WHEN
        sut.activateDIPToken("token") { result in
            switch result {
                case let .failure(error):
                    capturedError = error
                default:
                    XCTFail("Expected failure, got success")
            }
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedError, .generic(nil))
    }
    
    func test_activateDIPToken_fails_when_there_is_no_server() {
        // GIVEN
        let anyError = NSError(domain: "", code: 0)
        instantiateSut(server: nil, error: anyError)
        
        let expectation = expectation(description: "Waiting for activateDIPToken to complete")
        var capturedError: DedicatedIPError?
        
        // WHEN
        sut.activateDIPToken("token") { result in
            switch result {
                case let .failure(error):
                    capturedError = error
                default:
                    XCTFail("Expected failure, got success")
            }
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedError, .generic(anyError))
    }
}
