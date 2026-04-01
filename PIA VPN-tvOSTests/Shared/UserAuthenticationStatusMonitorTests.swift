//
//  UserAuthenticationStatusMonitorTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 18/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
import Combine
@testable import PIA_VPN_tvOS

final class UserAuthenticationStatusMonitorTests: XCTestCase {
    class Fixture {
        let notificationCenterMock = NotificationCenterMock()
    }
    
    var fixture: Fixture!
    var sut: UserAuthenticationStatusMonitor!
    var cancellables: Set<AnyCancellable>!
    var capturedUserAuthenticationStatus: [UserAuthenticationStatus]!
    
    override func setUp() {
        fixture = Fixture()
        cancellables = Set<AnyCancellable>()
        capturedUserAuthenticationStatus = [UserAuthenticationStatus]()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
        capturedUserAuthenticationStatus = nil
    }

    func test_observer_authStatus_change_when_newState_and_oldState_are_different() throws {
        // GIVEN
        let oldStatus = UserAuthenticationStatus.loggedOut
        let newState = UserAuthenticationStatus.loggedIn
        sut = UserAuthenticationStatusMonitor(currentStatus: oldStatus,
                                                  notificationCenter: fixture.notificationCenterMock)
        
        sut.getStatus().sink { status in
            self.capturedUserAuthenticationStatus.append(status)
        }.store(in: &cancellables)
        
        // WHEN
        sut.handleAccountDidLogin()
        
        // THEN
        XCTAssertEqual(capturedUserAuthenticationStatus, [oldStatus, newState])
    }
    
    func test_observer_authStatus_does_not_change_state_when_newState_and_oldState_are_the_same() throws {
        // GIVEN
        let status = UserAuthenticationStatus.loggedIn
        sut = UserAuthenticationStatusMonitor(currentStatus: status,
                                                  notificationCenter: fixture.notificationCenterMock)
        
        sut.getStatus().sink { status in
            self.capturedUserAuthenticationStatus.append(status)
        }.store(in: &cancellables)
        
        // WHEN
        sut.handleAccountDidLogin()
        
        // THEN
        XCTAssertEqual(capturedUserAuthenticationStatus, [status])
    }
}
