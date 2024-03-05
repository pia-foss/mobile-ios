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
        
        init() {
            notificationCenterMock.notificationPublisher = NotificationCenter.Publisher(center: NotificationCenter.default, name: Notification.Name.PIADaemonsDidPingServers)
        }
        
    }
    
    var fixture: Fixture!
    var sut: RefreshServersLatencyUseCase!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        
        sut = RefreshServersLatencyUseCase(client: fixture.clientMock, serverProvider: fixture.serverProviderMock, notificationCenter: fixture.notificationCenterMock)
        
    }
    
    func test_refreshServersLatency() {
        // GIVENT that there are 2 servers in total
        fixture.serverProviderMock.currentServersTypeResult = fixture.servers
        
        instantiateSut()
        XCTAssertEqual(sut.state, .none)
        XCTAssertFalse(fixture.clientMock.pingServersCalled)
        
        // WHEN the use case is called
        sut.callAsFunction()
        
        // THEN the state becomes 'updating'
        XCTAssertEqual(sut.state, .updating)
        
        // THEN the client is called to ping all the servers
        XCTAssertTrue(fixture.clientMock.pingServersCalled)
        XCTAssertEqual(fixture.clientMock.pingServersCalledAttempt, 1)
        XCTAssertEqual(fixture.clientMock.pingServersCalledWithServers.count, 2)
        
        // AND WHEN pinging finishes
        NotificationCenter.default.post(name: Notification.Name.PIADaemonsDidPingServers, object: nil)
        
        // THEN the state becomes 'updated'
        XCTAssertEqual(sut.state, .updated)
        
    }
    
}
