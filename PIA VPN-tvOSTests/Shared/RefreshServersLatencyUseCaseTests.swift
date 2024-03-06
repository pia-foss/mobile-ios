//
//  RefreshServersLatencyUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 3/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine
import XCTest
@testable import PIA_VPN_tvOS

class RefreshServersLatencyUseCaseTests: XCTestCase {
    
    class Fixture {
        let clientMock = ClientTypeMock()
        let serverProviderMock = ServerProviderMock()
        let notificationCenterMock = NotificationCenterMock()
        let servers = [ServerMock(), ServerMock()]
        let connectionStateMonitorMock = ConnectionStateMonitorMock()
        
        init() {
            notificationCenterMock.notificationPublisher = NotificationCenter.Publisher(center: NotificationCenter.default, name: Notification.Name.PIADaemonsDidPingServers)
        }
        
    }
    
    var fixture: Fixture!
    var sut: RefreshServersLatencyUseCase!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        fixture = Fixture()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
    }
    
    private func instantiateSut() {
        
        sut = RefreshServersLatencyUseCase(client: fixture.clientMock, serverProvider: fixture.serverProviderMock, notificationCenter: fixture.notificationCenterMock, connectionStateMonitor: fixture.connectionStateMonitorMock)
        
    }
    
    private func stubLatencyUpdated(minutesAgo: Int) {
        let timezone = TimeZone(identifier: "UTC")!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone
        let now = calendar.date(byAdding: .second, value: 0, to: Date())!
        let updatedOn = calendar.date(byAdding: .minute, value: -minutesAgo, to: now)
        
        sut.state = .updated(updatedOn)
    }
    
    
    
    private func subscribeToLatencyUpdated(with expectation: XCTestExpectation) {
        sut.$state
            .sink { newValue in
                if newValue.isUpdated {
                    expectation.fulfill()
                }
            }.store(in: &cancellables)
    }
    
    func test_refreshServersLatencyWhenVPNDisconnected() {
        // GIVEN that there are 2 servers in total
        fixture.serverProviderMock.currentServersTypeResult = fixture.servers
        // AND that the VPN is disconnected
        fixture.connectionStateMonitorMock.connectionState = .disconnected
        
        let expectation = expectation(description: "Latency becomes updated")
        
        instantiateSut()
        subscribeToLatencyUpdated(with: expectation)
        XCTAssertEqual(sut.state, .none)
        XCTAssertFalse(fixture.clientMock.pingServersCalled)
        XCTAssertNil(sut.timer)
        
        // WHEN the use case is called
        sut()
        
        // THEN the state becomes 'updating'
        XCTAssertEqual(sut.state, .updating)
        // AND the refresh timer is created
        XCTAssertNotNil(sut.timer)
        
        // THEN the client is called to ping all the servers
        XCTAssertTrue(fixture.clientMock.pingServersCalled)
        XCTAssertEqual(fixture.clientMock.pingServersCalledAttempt, 1)
        XCTAssertEqual(fixture.clientMock.pingServersCalledWithServers.count, 2)
        
        // AND WHEN pinging finishes
        NotificationCenter.default.post(name: Notification.Name.PIADaemonsDidPingServers, object: nil)
        
        wait(for: [expectation], timeout: 3)
        
        // THEN the state becomes 'updated'
        XCTAssertTrue(sut.state.isUpdated)
        
    }
    
    func test_refreshServersLatencyWhenVPNConnected() {
        // GIVEN that there are 2 servers in total
        fixture.serverProviderMock.currentServersTypeResult = fixture.servers
        // AND that the VPN is connected
        fixture.connectionStateMonitorMock.connectionState = .connected
        
        instantiateSut()
        XCTAssertEqual(sut.state, .none)
        XCTAssertFalse(fixture.clientMock.pingServersCalled)
        XCTAssertNil(sut.timer)
        
        // WHEN the use case is called
        sut()
        
        // THEN the refresh timer is created
        XCTAssertNotNil(sut.timer)
        
        // AND the client is NOT called to ping all the servers
        XCTAssertFalse(fixture.clientMock.pingServersCalled)
        XCTAssertEqual(fixture.clientMock.pingServersCalledAttempt, 0)
        
        // THEN the state remains 'none'
        XCTAssertEqual(sut.state, .none)
        
    }
    
    func test_stopRefreshingServerversLatency() {
        fixture.connectionStateMonitorMock.connectionState = .disconnected
        instantiateSut()
        
        // GIVEN that the servers latency was being updated
        sut()
        XCTAssertNotNil(sut.timer)
        XCTAssertEqual(sut.state, .updating)
        
        // WHEN calling the stop method
        sut.stop()
        
        // THEN the timer becomes nil
        XCTAssertNil(sut.timer)
        // AND the state becomes 'none'
        XCTAssertEqual(sut.state, .none)
        
    }
    
    func test_refreshServersLatencyAfter4minutes() {
        // GIVEN that the VPN is disconnected
        fixture.connectionStateMonitorMock.connectionState = .disconnected
        
        instantiateSut()
        // AND the latency was updated 4 minutes ago
        stubLatencyUpdated(minutesAgo: 4)
        
        // WHEN the use case is called
        sut()
        
        // THEN the client is NOT called to ping the servers
        XCTAssertFalse(fixture.clientMock.pingServersCalled)
        XCTAssertEqual(fixture.clientMock.pingServersCalledAttempt, 0)
        // AND the state remains 'updated'
        XCTAssertTrue(sut.state.isUpdated)
        
    }
    
    func test_refreshServersLatencyAfter5minutes() {
        // GIVEN that the VPN is disconnected
        fixture.connectionStateMonitorMock.connectionState = .disconnected
        
        instantiateSut()
        // AND the latency was updated 5 minutes ago
        stubLatencyUpdated(minutesAgo: 5)
        
        // WHEN the use case is called
        sut()
        
        // THEN the client is called to ping the servers
        XCTAssertTrue(fixture.clientMock.pingServersCalled)
        XCTAssertEqual(fixture.clientMock.pingServersCalledAttempt, 1)
        // AND the state becomes 'updating'
        XCTAssertEqual(sut.state, .updating)
    }
    
}
