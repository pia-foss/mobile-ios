//
//  VPNStatusMonitorTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 18/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
import Combine
import PIALibrary
@testable import PIA_VPN_tvOS

final class VPNStatusMonitorTests: XCTestCase {
    class Fixture {
        let notificationCenterMock = NotificationCenterMock()
        
        func makeVPNStatusProvider(result: VPNStatus) -> VPNStatusProviderMock {
            return VPNStatusProviderMock(vpnStatus: result)
        }
    }
    
    var fixture: Fixture!
    var sut: VPNStatusMonitor!
    var cancellables: Set<AnyCancellable>!
    var capturedVPNStatus: [VPNStatus]!
    
    override func setUp() {
        fixture = Fixture()
        cancellables = Set<AnyCancellable>()
        capturedVPNStatus = [VPNStatus]()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
        capturedVPNStatus = nil
    }

    func test_observer_vpnStatus_change_when_newState_and_oldState_are_different() {
        // GIVEN
        let oldStatus = VPNStatus.connected
        let newState = VPNStatus.disconnected
        let vpnStatusProvider = fixture.makeVPNStatusProvider(result: oldStatus)
        sut = VPNStatusMonitor(vpnStatusProvider: vpnStatusProvider,
                               notificationCenter: fixture.notificationCenterMock)
        
        sut.getStatus().sink { status in
            self.capturedVPNStatus.append(status)
        }.store(in: &cancellables)
        
        // WHEN
        vpnStatusProvider.changeStatus(vpnStatus: newState)
        sut.vpnStatusDidChange(notification: Notification(name: Notification.Name("")))
        
        // THEN
        XCTAssertEqual(capturedVPNStatus, [oldStatus, newState])
    }
    
    func test_observer_vpnStatus_does_not_change_state_when_newState_and_oldState_are_the_same() throws {
        // GIVEN
        let status = VPNStatus.connected
        sut = VPNStatusMonitor(vpnStatusProvider: fixture.makeVPNStatusProvider(result: status),
                               notificationCenter: fixture.notificationCenterMock)
        
        sut.getStatus().sink { status in
            self.capturedVPNStatus.append(status)
        }.store(in: &cancellables)
        
        // WHEN
        sut.vpnStatusDidChange(notification: Notification(name: Notification.Name("")))
        
        // THEN
        XCTAssertEqual(capturedVPNStatus, [status])
    }
}
