//
//  ProtectedDataGateTests.swift
//  PIA VPNTests
//
//  Created by Mario on 22/10/26.
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import XCTest

@testable import PIA_VPN

final class ProtectedDataGateTests: XCTestCase {

    private var notificationCenter: NotificationCenter!

    override func setUp() {
        super.setUp()
        notificationCenter = NotificationCenter()
    }

    func test_runsImmediately_whenProtectedDataIsAvailable() {
        let sut = ProtectedDataGate(isProtectedDataAvailable: { true }, notificationCenter: notificationCenter)
        var runs = 0

        sut.whenAvailable { runs += 1 }

        XCTAssertEqual(runs, 1)
    }

    func test_defersUntilUnlock_whenProtectedDataIsUnavailable() {
        let sut = ProtectedDataGate(isProtectedDataAvailable: { false }, notificationCenter: notificationCenter)
        var runs = 0

        sut.whenAvailable { runs += 1 }
        XCTAssertEqual(runs, 0)

        notificationCenter.post(name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        XCTAssertEqual(runs, 1)
    }

    func test_runsOnce_whenUnlockedRepeatedly() {
        let sut = ProtectedDataGate(isProtectedDataAvailable: { false }, notificationCenter: notificationCenter)
        var runs = 0

        sut.whenAvailable { runs += 1 }
        notificationCenter.post(name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        notificationCenter.post(name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)

        XCTAssertEqual(runs, 1)
    }
}
