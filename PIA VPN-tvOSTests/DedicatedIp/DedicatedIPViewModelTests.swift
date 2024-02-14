//
//  DedicatedIPViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 20/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS
import Combine

final class DedicatedIPViewModelTests: XCTestCase {
    class Fixture {
        var getDedicatedIpUseCaseMock: GetDedicatedIpUseCaseMock!
        let removeDIPUseCaseMock = RemoveDIPUseCaseMock()
        let activateDIPTokenUseCaseMock = ActivateDIPTokenUseCaseMock()
    }
    
    var fixture: Fixture!
    var sut: DedicatedIPViewModel!
    var cancellables: Set<AnyCancellable>!
    
    func instantiateSut(getDedicatedIpResult: ServerType?) {
        fixture.getDedicatedIpUseCaseMock = GetDedicatedIpUseCaseMock(result: getDedicatedIpResult)
        sut = DedicatedIPViewModel(getDedicatedIp: fixture.getDedicatedIpUseCaseMock,
                                   activateDIPToken: fixture.activateDIPTokenUseCaseMock,
                                   removeDIPToken: fixture.removeDIPUseCaseMock)
    }

    override func setUp() {
        fixture = Fixture()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
    }

    func test_onAppear_updates_dedicateIP_when_getDedicatedIpUseCase_returns_valid_DIP() {
        // GIVEN
        let server = ServerTypeStub.makeValidServerTypeStub()
        let expectedStats = [
            DedicatedIpData(title: L10n.Localizable.Settings.Dedicatedip.Stats.dedicatedip, description: "dipStatusString"),
            DedicatedIpData(title: L10n.Localizable.Settings.Dedicatedip.Stats.ip, description: "dipIKEv2IP"),
            DedicatedIpData(title: L10n.Localizable.Settings.Dedicatedip.Stats.location, description: "name (country)")
        ]
        
        instantiateSut(getDedicatedIpResult: server)
        
        let expectation = expectation(description: "Wait for dedicatedIPStats to be updated")
        
        sut.$dedicatedIPStats.dropFirst().sink(receiveValue: { stats in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.onAppear()
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.dedicatedIPStats, expectedStats)
    }
    
    func test_onAppear_updates_dedicateIP_when_getDedicatedIpUseCase_returns_nonvalid_DIP() {
        // GIVEN
        let server = ServerTypeStub.makeNonValidServerTypeStub()
        instantiateSut(getDedicatedIpResult: server)
        
        let expectation = expectation(description: "Wait for dedicatedIPStats to be updated")
        
        sut.$dedicatedIPStats.dropFirst().sink(receiveValue: { stats in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        sut.onAppear()
        
        // THEN
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.dedicatedIPStats, [])
    }
    
    func test_activateDIP_updates_dedicateIP_when_activateDIPTokenUseCase_succeeds_and_getDedicatedIpUseCase_returns_valid_DIP() async {
        // GIVEN
        let server = ServerTypeStub.makeValidServerTypeStub()
        let expectedStats = [
            DedicatedIpData(title: L10n.Localizable.Settings.Dedicatedip.Stats.dedicatedip, description: "dipStatusString"),
            DedicatedIpData(title: L10n.Localizable.Settings.Dedicatedip.Stats.ip, description: "dipIKEv2IP"),
            DedicatedIpData(title: L10n.Localizable.Settings.Dedicatedip.Stats.location, description: "name (country)")
        ]
        
        instantiateSut(getDedicatedIpResult: server)
        
        let expectation = expectation(description: "Wait for dedicatedIPStats to be updated")
        
        sut.$dedicatedIPStats.dropFirst().sink(receiveValue: { stats in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        await sut.activateDIP(token: "token")
        
        // THEN
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertFalse(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.dedicatedIPStats, expectedStats)
    }
    
    func test_activateDIP_shows_error_when_activateDIPTokenUseCase_fails() async {
        // GIVEN
        let server = ServerTypeStub.makeValidServerTypeStub()
        instantiateSut(getDedicatedIpResult: server)
        fixture.activateDIPTokenUseCaseMock.error = NSError(domain: "", code: 0)
        
        let expectation = expectation(description: "Wait for dedicatedIPStats to be updated")
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN
        await sut.activateDIP(token: "token")
        
        // THEN
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.dedicatedIPStats, [])
    }
    
    func test_removeDIP_updates_dedicateIP_when_removeDIPUseCaseMock_succeeds() {
        // GIVEN
        let server = ServerTypeStub.makeNonValidServerTypeStub()
        instantiateSut(getDedicatedIpResult: server)
        
        // WHEN
        sut.removeDIP()
        
        // THEN
        XCTAssertEqual(sut.dedicatedIPStats, [])
        XCTAssertEqual(fixture.removeDIPUseCaseMock.useCaseWasCalled, 1)
    }
}

private struct ServerTypeStub: ServerType {
    var name: String
    var identifier: String
    var regionIdentifier: String
    var country: String
    var geo: Bool
    var pingTime: Int?
    var isAutomatic: Bool
    var dipToken: String?
    var dipIKEv2IP: String?
    var dipStatusString: String?
    
    static func makeValidServerTypeStub() -> ServerType {
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
    
    static func makeNonValidServerTypeStub() -> ServerType {
        ServerTypeStub(name: "name",
                       identifier: "identifier",
                       regionIdentifier: "regionIdentifier",
                       country: "country",
                       geo: false,
                       pingTime: 0,
                       isAutomatic: true,
                       dipToken: "dipToken",
                       dipIKEv2IP: nil,
                       dipStatusString: nil)
    }
}

extension DedicatedIpData: Equatable {
    public static func == (lhs: DedicatedIpData, rhs: DedicatedIpData) -> Bool {
        lhs.title == rhs.title
        && lhs.description == rhs.description
    }
}
