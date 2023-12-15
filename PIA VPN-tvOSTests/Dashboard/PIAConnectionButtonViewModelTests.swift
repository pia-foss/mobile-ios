//
//  PIAConnectionButtonViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 12/14/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest
import Combine
@testable import PIA_VPN_tvOS

final class PIAConnectionButtonViewModelTests: XCTestCase {
    
    final class Fixture {
        let vpnConnectionUseCaseMock = VpnConnectionUseCaseMock()
    }
    
    var fixture: Fixture!
    var sut: PIAConnectionButtonViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        fixture = Fixture()
        sut = PIAConnectionButtonViewModel(useCase: fixture.vpnConnectionUseCaseMock)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
    }
    
    func test_toggleConnection_when_disconnected() {
        // GIVEN that the vpn state is disconnected
        XCTAssertTrue(sut.state == .disconnected)
        
        let connectingExpectation = expectation(description: "vpn is connecting")
        
        let connectedExpectation = expectation(description: "vpn is connected")
        
        sut.$state.sink { _ in
        } receiveValue: { state in
            switch state {
            case .connecting:
                connectingExpectation.fulfill()
            case .connected:
                connectedExpectation.fulfill()
            default: break
            }
        }.store(in: &cancellables)

        
        // WHEN calling the toggle connection method
        sut.toggleConnection()
        
        // THEN the vpnConnectionUseCase is called once to connect the vpn
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.connectCalled)
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.connectCalledAttempt == 1)
        
        // AND the Vpn state becomes 'connecting' and 'connected'
        wait(for: [connectingExpectation, connectedExpectation], timeout: 1)
        XCTAssertEqual(sut.state, .connected)
        
    }
    
    func test_toggleConnection_when_connected() {
        // GIVEN that the vpn state is connected
        sut.state = .connected
        XCTAssertTrue(sut.state == .connected)
        
        let disconnectingExpectation = expectation(description: "vpn is disconnecting")
        
        let disconnectedExpectation = expectation(description: "vpn is disconnected")
        
        sut.$state.sink { _ in
        } receiveValue: { state in
            switch state {
            case .disconnecting:
                disconnectingExpectation.fulfill()
            case .disconnected:
                disconnectedExpectation.fulfill()
            default: break
            }
        }.store(in: &cancellables)

        
        // WHEN calling the toggle connection method
        sut.toggleConnection()
        
        // THEN the vpnConnectionUseCase is called once to disconnect the vpn
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.disconnectCalled)
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.disconnectCalledAttempt == 1)
        
        // AND the Vpn state becomes 'disconnecting' and 'disconnected'
        wait(for: [disconnectingExpectation, disconnectedExpectation], timeout: 1)
        XCTAssertEqual(sut.state, .disconnected)
        
    }
    
}
