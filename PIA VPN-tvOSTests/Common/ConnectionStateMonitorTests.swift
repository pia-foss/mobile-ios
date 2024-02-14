//
//  ConnectionStateMonitorTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/13/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//



import Combine
import XCTest
@testable import PIA_VPN_tvOS
import PIALibrary

class ConnectionStateMonitorTests: XCTestCase {
    class Fixture {
        let vpnStatusMonitorMock = VPNStatusMonitorMock()
        let vpnConnectionUseCaseMock = VpnConnectionUseCaseMock()
    }
    
    var fixture: Fixture!
    var sut: ConnectionStateMonitor!
    var capturedConnectionStates = [ConnectionState]()
    var cancellables = Set<AnyCancellable>()
    
    private func instantiateSut() {
        sut = ConnectionStateMonitor(vpnStatusMonitor: fixture.vpnStatusMonitorMock, vpnConnectionUseCase: fixture.vpnConnectionUseCaseMock)
    }
    
    override func setUp() {
        fixture = Fixture()
        capturedConnectionStates = []
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func fulfillOnConnectionState(_ expectedState: ConnectionState, expectation: XCTestExpectation) {
        sut.connectionStatePublisher.sink { [weak self] newConnectionState in
            self?.capturedConnectionStates.append(newConnectionState)
            if newConnectionState == expectedState {
                expectation.fulfill()
            }
        }.store(in: &cancellables)
    }
    
    func test_connectionStateWhen_statusDisconnected_intentConnect() {
        instantiateSut()
        let connectionStateExp = expectation(description: "Wait for expected conn state")
        fulfillOnConnectionState(.connecting, expectation: connectionStateExp)
        
        // GIVEN that the conection intent is 'connect'
        fixture.vpnConnectionUseCaseMock.getConnectionIntentResult.send(.connect)
        
        // AND GIVEN that the vpn status is disconnected
        fixture.vpnStatusMonitorMock.status.send(.disconnected)

        wait(for: [connectionStateExp], timeout: 3)
        // THEN the connection state is 'connecting'
        XCTAssertEqual(capturedConnectionStates.last!, .connecting)
        
    }
    
    func test_connectionStateWhen_statusConnecting_intentDisconnect() {
        fixture.vpnStatusMonitorMock.status.send(.disconnecting)
        instantiateSut()
        let connectionStateExp = expectation(description: "Wait for expected conn state")
        fulfillOnConnectionState(.disconnecting, expectation: connectionStateExp)
        
        // GIVEN that the conection intent is 'disconnect'
        fixture.vpnConnectionUseCaseMock.getConnectionIntentResult.send(.disconnect)
        
        // AND GIVEN that the vpn status is connecting
        fixture.vpnStatusMonitorMock.status.send(.connecting)

        
        wait(for: [connectionStateExp], timeout: 3)
        // THEN the connection state is 'disconnecting'
        XCTAssertEqual(capturedConnectionStates.last!, .disconnecting )
        
    }
    
    func test_connectionStateWhen_statusConnected_intentNone() {
        fixture.vpnStatusMonitorMock.status.send(.connecting)
        instantiateSut()
        let connectionStateExp = expectation(description: "Wait for expected conn state")
        fulfillOnConnectionState(.connected, expectation: connectionStateExp)
        
        // GIVEN that the conection intent is 'none'
        fixture.vpnConnectionUseCaseMock.getConnectionIntentResult.send(.none)
        
        // AND GIVEN that the vpn status is connected
        fixture.vpnStatusMonitorMock.status.send(.connected)

        
        wait(for: [connectionStateExp], timeout: 3)
        // THEN the connection state is 'connected'
        XCTAssertEqual(capturedConnectionStates.last!, .connected )
        
    }
    
    func test_connectionStateWhen_statusConnected_intentConnect() {
        fixture.vpnStatusMonitorMock.status.send(.connecting)
        instantiateSut()
        let connectionStateExp = expectation(description: "Wait for expected conn state")
        fulfillOnConnectionState(.connected, expectation: connectionStateExp)
        
        // GIVEN that the conection intent is 'connect'
        fixture.vpnConnectionUseCaseMock.getConnectionIntentResult.send(.connect)
        
        // AND GIVEN that the vpn status is connected
        fixture.vpnStatusMonitorMock.status.send(.connected)

        
        wait(for: [connectionStateExp], timeout: 3)
        // THEN the connection state is 'connected'
        XCTAssertEqual(capturedConnectionStates.last!, .connected )
        
    }
    
    func test_connectionStateWhen_statusConnected_intentDisconnect() {
        fixture.vpnStatusMonitorMock.status.send(.connecting)
        instantiateSut()
        let connectionStateExp = expectation(description: "Wait for expected conn state")
        fulfillOnConnectionState(.connected, expectation: connectionStateExp)
        
        // GIVEN that the conection intent is 'disconnect'
        fixture.vpnConnectionUseCaseMock.getConnectionIntentResult.send(.disconnect)
        
        // AND GIVEN that the vpn status is connected
        fixture.vpnStatusMonitorMock.status.send(.connected)

        
        wait(for: [connectionStateExp], timeout: 3)
        // THEN the connection state is 'connected'
        XCTAssertEqual(capturedConnectionStates.last!, .connected )
        
    }
    
    
    func test_connectionStateWhen_errorInConnectionIntent() {
        fixture.vpnStatusMonitorMock.status.send(.connecting)
        instantiateSut()
        let connectionError: Error = NSError(domain: "test.connection_error", code: 1) as Error
        let connectionStateExp = expectation(description: "Wait for expected conn state")
        fulfillOnConnectionState(.error(connectionError), expectation: connectionStateExp)
        
        // AND GIVEN that the vpn status is connected
        fixture.vpnStatusMonitorMock.status.send(.connected)
       
        // AND GIVEN that the conection intent stops with an error
        fixture.vpnConnectionUseCaseMock.getConnectionIntentResult.send(completion: .failure(connectionError))
        
        wait(for: [connectionStateExp], timeout: 3)
        
        // THEN the connection state becomes 'error'
        XCTAssertEqual(capturedConnectionStates.last!, .error(connectionError) )
        
    }
    
}
