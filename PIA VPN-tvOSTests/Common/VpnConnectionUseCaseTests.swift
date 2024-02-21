//
//  VpnConnectionUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/13/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
import Combine

@testable import PIA_VPN_tvOS

class VpnConnectionUseCaseTests: XCTestCase {
    class Fixture {
        let serverProviderMock = ServerProviderMock()
        let vpnProviderMock = VPNStatusProviderMock(vpnStatus: .disconnected)
        let vpnStatusMonitorMock = VPNStatusMonitorMock()
    }
    private var subscriptions = Set<AnyCancellable>()
    private var capturedConnectionIntents: [VpnConnectionIntent] = []
    var fixture: Fixture!
    var sut: VpnConnectionUseCase!
    
    override func setUp() {
        fixture = Fixture()
        subscriptions = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        capturedConnectionIntents = []
    }
    
    private func instantiateSut() {
        sut = VpnConnectionUseCase(serverProvider: fixture.serverProviderMock , vpnProvider: fixture.vpnProviderMock, vpnStatusMonitor: fixture.vpnStatusMonitorMock)
    }
    
    private func captureConnectionIntents(expectationToFulfill: XCTestExpectation, intentsCount: Int) {
        sut.connectionIntent
            .sink { _ in

            } receiveValue: { newIntent in
                self.capturedConnectionIntents.append(newIntent)
                if self.capturedConnectionIntents.count == intentsCount {
                    expectationToFulfill.fulfill()
                }
            }.store(in: &subscriptions)

    }
    
    func test_connect() async throws {
        // GIVEN that there is no error connecting the vpn provider
        fixture.vpnProviderMock.connectCalledWithCallbackError = nil
        
        instantiateSut()
        
        let vpnConnectedExpectation = expectation(description: "The VPN status becomes Connected")
        captureConnectionIntents(expectationToFulfill: vpnConnectedExpectation, intentsCount: 3)

        // The initial state of the connection intent is 'none'
        XCTAssertEqual(sut.connectionIntent.value, .none)

        // WHEN trying to connect
        try await sut.connect()
        
        // THEN the connection intent becomes 'connect'
        XCTAssertEqual(sut.connectionIntent.value, .connect)
        
        // AND the vpn provider is called to connect once
        XCTAssertTrue(fixture.vpnProviderMock.connectCalled)
        XCTAssertEqual(fixture.vpnProviderMock.connectCalledAttempt, 1)
        
        // AND WHEN the connection succeeds
        fixture.vpnStatusMonitorMock.status.send(.connected)
        
        wait(for: [vpnConnectedExpectation], timeout: 5)
        
        // THEN the connection intent is set back to 'none'
        XCTAssertEqual(sut.connectionIntent.value, .none)
        
        
        
    }
    
    func test_connect_when_vpnProvider_sendsError() async throws {
        // GIVEN that there is an error connecting the vpn provider
        fixture.vpnProviderMock.connectCalledWithCallbackError = NSError(domain: "com.piavpn.tests", code: 1)
        
        instantiateSut()
        // The initial state of the connection intent is 'none'
        XCTAssertEqual(sut.connectionIntent.value, .none)
        
        var connectionIntentFinishedError: Error?
        sut.getConnectionIntent()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    connectionIntentFinishedError = error
                default:
                    break
                }
            } receiveValue: { newValue in
            }.store(in: &subscriptions)
        
        // WHEN trying to connect
        try? await sut.connect()
        // THEN an error is thown
        XCTAssertNotNil(connectionIntentFinishedError)
    }
    
    func test_disconnect() async throws {
        // GIVEN that there is no error disconnecting the vpn provider
        fixture.vpnProviderMock.disconnectCalledWithCallbackError = nil
        
        instantiateSut()
        
        let vpnDisconnectedExpectation = expectation(description: "The VPN status becomes Disconnected")
        captureConnectionIntents(expectationToFulfill: vpnDisconnectedExpectation, intentsCount: 3)
        
        // The initial state of the connection intent is 'none'
        XCTAssertEqual(sut.connectionIntent.value, .none)

        // WHEN trying to disconnect
        try await sut.disconnect()
        
        // THEN the connection intent becomes 'disconnect'
        XCTAssertEqual(sut.connectionIntent.value, .disconnect)
        
        // AND the vpn provider is called to disconnect once
        XCTAssertTrue(fixture.vpnProviderMock.disconnectCalled)
        XCTAssertEqual(fixture.vpnProviderMock.disconnectCalledAttempt, 1)
        
        // AND WHEN the disconnection succeeds
        fixture.vpnStatusMonitorMock.status.send(.disconnected)
        
        wait(for: [vpnDisconnectedExpectation], timeout: 5)
        
        // THEN the connection intent is set back to 'none'
        XCTAssertEqual(sut.connectionIntent.value, .none)
    }
    
    func test_disconnect_when_vpnProvider_sendsError() async throws {
        // GIVEN that there is an error disconnecting the vpn provider
        fixture.vpnProviderMock.disconnectCalledWithCallbackError = NSError(domain: "com.piavpn.tests", code: 1)
        
        instantiateSut()
        // The initial state of the connection intent is 'none'
        XCTAssertEqual(sut.connectionIntent.value, .none)
        
        var disconnectionIntentFinishedError: Error?
        sut.getConnectionIntent()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    disconnectionIntentFinishedError = error
                default:
                    break
                }
            } receiveValue: { newValue in
            }.store(in: &subscriptions)
        
        // WHEN trying to disconnect
        try? await sut.disconnect()
        // THEN an error is thown
        XCTAssertNotNil(disconnectionIntentFinishedError)
    }
    
}
