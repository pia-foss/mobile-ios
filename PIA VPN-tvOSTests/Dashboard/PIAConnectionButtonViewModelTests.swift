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
        let vpnStatusMonitor = VPNStatusMonitorMock()
    }
    
    var fixture: Fixture!
    var sut: PIAConnectionButtonViewModel!
    var cancellables: Set<AnyCancellable>!
    var capturedState: [PIAConnectionButtonViewModel.State]!
    
    override func setUp() {
        fixture = Fixture()
        sut = PIAConnectionButtonViewModel(useCase: fixture.vpnConnectionUseCaseMock, 
                                           vpnStatusMonitor: fixture.vpnStatusMonitor)
        cancellables = Set<AnyCancellable>()
        capturedState = [PIAConnectionButtonViewModel.State]()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
        capturedState = nil
    }
    
    func test_toggleConnection_when_disconnected() {
        // GIVEN that the vpn state is disconnected
        XCTAssertTrue(sut.state == .disconnected)
        
        fixture.vpnConnectionUseCaseMock.connectionAction = { [weak self] in
            self?.fixture.vpnStatusMonitor.status.send(.connecting)
            self?.fixture.vpnStatusMonitor.status.send(.connected)
        }
        
        fixture.vpnConnectionUseCaseMock.disconnectionAction = { [weak self] in
            self?.fixture.vpnStatusMonitor.status.send(.disconnecting)
            self?.fixture.vpnStatusMonitor.status.send(.disconnected)
        }
        
        capturedState = [PIAConnectionButtonViewModel.State]()
        
        sut.$state.sink { _ in
        } receiveValue: { state in
            self.capturedState.append(state)
        }.store(in: &cancellables)
         
        
        // WHEN calling the toggle connection method
        sut.toggleConnection()
        
        // THEN the vpnConnectionUseCase is called once to connect the vpn
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.connectCalled)
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.connectCalledAttempt == 1)
        
        // AND the Vpn state becomes 'connecting' and 'connected'
        XCTAssertEqual(capturedState, [.disconnected, .connecting, .connected])
    }
    
    func test_toggleConnection_when_connected() {
        // GIVEN that the vpn state is connected
        sut.state = .connected
        XCTAssertTrue(sut.state == .connected)
        
        fixture.vpnConnectionUseCaseMock.connectionAction = { [weak self] in
            self?.fixture.vpnStatusMonitor.status.send(.connecting)
            self?.fixture.vpnStatusMonitor.status.send(.connected)
        }
        
        fixture.vpnConnectionUseCaseMock.disconnectionAction = { [weak self] in
            self?.fixture.vpnStatusMonitor.status.send(.disconnecting)
            self?.fixture.vpnStatusMonitor.status.send(.disconnected)
        }
        
        capturedState = [PIAConnectionButtonViewModel.State]()
        
        sut.$state.sink { _ in
        } receiveValue: { state in
            self.capturedState.append(state)
        }.store(in: &cancellables)

        
        // WHEN calling the toggle connection method
        sut.toggleConnection()
        
        // THEN the vpnConnectionUseCase is called once to disconnect the vpn
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.disconnectCalled)
        XCTAssertTrue(fixture.vpnConnectionUseCaseMock.disconnectCalledAttempt == 1)
        
        // AND the Vpn state becomes 'disconnecting' and 'disconnected'
        XCTAssertEqual(capturedState, [.connected, .disconnecting, .disconnected])
    }
    
}
