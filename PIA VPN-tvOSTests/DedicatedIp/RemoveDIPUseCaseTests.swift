//
//  RemoveDIPUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 22/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS

final class RemoveDIPUseCaseTests: XCTestCase {
    class Fixture {
        var dipServerProviderMock = DedicatedIPProviderMock(result: .success(()))
        var favoriteRegionsUseCaseMock = FavoriteRegionUseCaseMock()
        var getDedicatedIPUseCaseMock: GetDedicatedIpUseCaseMock!
        var vpnConnectionUseCaseMock = VpnConnectionUseCaseMock()
        var clientPreferencesMock: ClientPreferencesMock!
    }
    
    var fixture: Fixture!
    var sut: RemoveDIPUseCase!
    
    func instantiateSut(result: ServerType?, selectedServer: ServerType) {
        fixture.getDedicatedIPUseCaseMock = GetDedicatedIpUseCaseMock(result: result)
        fixture.clientPreferencesMock = ClientPreferencesMock()
        fixture.clientPreferencesMock.selectedServer = selectedServer
        //(selectedServer: selectedServer)
        sut = RemoveDIPUseCase(dedicatedIpProvider: fixture.dipServerProviderMock,
                               favoriteRegionsUseCase: fixture.favoriteRegionsUseCaseMock,
                               getDedicatedIP: fixture.getDedicatedIPUseCaseMock,
                               vpnCpnnectionUseCase: fixture.vpnConnectionUseCaseMock,
                               selectedServer: fixture.clientPreferencesMock)
    }

    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }

    func test_removeDIPToken_complets_successfully_when_dedicatedIp_was_found_and_connected() {
        // GIVEN
        let server = ServerTypeStub.makesServer1()
        instantiateSut(result: server, selectedServer: server)
        
        let expectation = expectation(description: "Waiting for vpnConnectionUseCaseMock to be called")
        fixture.vpnConnectionUseCaseMock.disconnectionAction = {
            expectation.fulfill()
        }
        // WHEN
        sut()
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(fixture.dipServerProviderMock.requests, [.removeDIPToken])
        XCTAssertEqual(fixture.favoriteRegionsUseCaseMock.removeFromFavoritesCalledAttempt, 1)
        XCTAssertEqual(fixture.vpnConnectionUseCaseMock.disconnectCalledAttempt, 1)
    }
    
    func test_removeDIPToken_complets_successfully_when_dedicatedIp_was_found_and_not_connected() {
        // GIVEN
        let server = ServerTypeStub.makesServer1()
        let selectedServer = ServerTypeStub.makesServer2()
        instantiateSut(result: server, selectedServer: selectedServer)
        
        fixture.vpnConnectionUseCaseMock.disconnectionAction = {
            XCTFail("Unexpected call to vpnConnectionUseCaseMock")
        }
        // WHEN
        sut()
        
        // THEN
        XCTAssertEqual(fixture.dipServerProviderMock.requests, [.removeDIPToken])
        XCTAssertEqual(fixture.favoriteRegionsUseCaseMock.removeFromFavoritesCalledAttempt, 1)
        XCTAssertEqual(fixture.vpnConnectionUseCaseMock.disconnectCalledAttempt, 0)
    }
    
    func test_activatesDIPToken_complets_with_failure_when_DedicatedIPProvider_complets_with_failure() {
        // GIVEN
        instantiateSut(result: nil, selectedServer: ServerTypeStub.makeValidServerTypeStub())
        fixture.vpnConnectionUseCaseMock.disconnectionAction = {
            XCTFail("Unexpected call to vpnConnectionUseCaseMock")
        }
        
        // WHEN
        sut()
        
        // THEN
        XCTAssertEqual(fixture.dipServerProviderMock.requests, [])
        XCTAssertEqual(fixture.favoriteRegionsUseCaseMock.removeFromFavoritesCalledAttempt, 0)
        XCTAssertEqual(fixture.vpnConnectionUseCaseMock.disconnectCalledAttempt, 0)
    }
}

extension ServerTypeStub {
    static func makesServer1() -> ServerType {
        ServerTypeStub(name: "name",
                       identifier: "identifier",
                       regionIdentifier: "regionIdentifier",
                       country: "country",
                       geo: false,
                       pingTime: 0,
                       isAutomatic: true,
                       dipToken: "dipToken",
                       dipIKEv2IP: "dipIKEv2IP",
                       dipStatusString: "dipStatusString")
    }

    static func makesServer2() -> ServerType {
        ServerTypeStub(name: "name2",
                       identifier: "identifier2",
                       regionIdentifier: "regionIdentifier2",
                       country: "country2",
                       geo: false,
                       pingTime: 0,
                       isAutomatic: true,
                       dipToken: "dipToken",
                       dipIKEv2IP: "dipIKEv2IP2",
                       dipStatusString: "dipStatusString")
    }
}
