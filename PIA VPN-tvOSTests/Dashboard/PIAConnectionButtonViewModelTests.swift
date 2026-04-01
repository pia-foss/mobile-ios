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
        let connectionStateMonitorMock = ConnectionStateMonitorMock()
    }
    
    var fixture: Fixture!
    var sut: PIAConnectionButtonViewModel!
    var cancellables: Set<AnyCancellable>!
    var capturedState: [ConnectionState]!
    
    override func setUp() {
        fixture = Fixture()
        cancellables = Set<AnyCancellable>()
        capturedState = [ConnectionState]()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
        capturedState = nil
    }
    
    private func instantiateSut() {
        sut = PIAConnectionButtonViewModel(useCase: fixture.vpnConnectionUseCaseMock,
                                           connectionStateMonitor: fixture.connectionStateMonitorMock)
    }
    
    func test_toggleConnection_when_disconnected() {
        // GIVEN that the connection state is disconnected
        fixture.connectionStateMonitorMock.connectionState = .disconnected
        
        let connectExpectation = XCTestExpectation(description: "connection is called")
        fixture.vpnConnectionUseCaseMock.connectionAction = { [weak self] in
            self?.fixture.connectionStateMonitorMock.connectionState = .connecting
            self?.fixture.connectionStateMonitorMock.connectionState = .connected
            connectExpectation.fulfill()
        }
        
        instantiateSut()
        XCTAssertTrue(sut.state == .disconnected)
        
        sut.$state.sink { _ in
        } receiveValue: { state in
            self.capturedState.append(state)
        }.store(in: &cancellables)
         
        // WHEN calling the toggle connection method
        sut.toggleConnection()
        
        wait(for: [connectExpectation], timeout: 3)
        // THEN the vpnConnectionUseCase is called once to connect the vpn
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.connectCalled)
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.connectCalledAttempt == 1)
        
        // AND the Vpn state becomes 'connecting' and 'connected'
        XCTAssertEqual(capturedState, [.disconnected, .connecting, .connected])
    }
    
    func test_toggleConnection_when_connected() {
        
        // GIVEN that the vpn state is connected
        fixture.connectionStateMonitorMock.connectionState = .connected
        
        let disconnectExpectation = XCTestExpectation(description: "Disconnect is called")
        fixture.vpnConnectionUseCaseMock.disconnectionAction = { [weak self] in
            self?.fixture.connectionStateMonitorMock.connectionState = .disconnecting
            self?.fixture.connectionStateMonitorMock.connectionState = .disconnected
            disconnectExpectation.fulfill()
        }
        
        instantiateSut()
        XCTAssertTrue(sut.state == .connected)
        
        
        sut.$state.sink { _ in
        } receiveValue: { state in
            self.capturedState.append(state)
        }.store(in: &cancellables)

        
        // WHEN calling the toggle connection method
        sut.toggleConnection()
        
        wait(for: [disconnectExpectation], timeout: 3)
        
        // THEN the vpnConnectionUseCase is called once to disconnect the vpn
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.disconnectCalled)
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.disconnectCalledAttempt == 1)
        
        // AND the Vpn state becomes 'disconnecting' and 'disconnected'
        XCTAssertEqual(capturedState, [.connected, .disconnecting, .disconnected])
    }
    
}
