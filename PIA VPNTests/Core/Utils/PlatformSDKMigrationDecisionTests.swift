//
//  PlatformSDKMigrationDecisionTests.swift
//  PIA VPN
//
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

import PIALibrary
import XCTest

@testable import PIA_VPN

final class PlatformSDKMigrationDecisionTests: XCTestCase {

    // MARK: - shouldReconnectAfterCleanup

    func testReconnectsWhenTheTunnelIsStillLive() {
        XCTAssertTrue(
            PlatformSDKMigrationDecision.shouldReconnectAfterCleanup(
                isNativeLive: true,
                isOnDemandArmed: false,
                lastKnownStatus: .disconnected
            )
        )
    }

    func testReconnectsWhenOnDemandIsArmedButTheTunnelReadsDown() {
        XCTAssertTrue(
            PlatformSDKMigrationDecision.shouldReconnectAfterCleanup(
                isNativeLive: false,
                isOnDemandArmed: true,
                lastKnownStatus: .disconnected
            )
        )
    }

    func testReconnectsOnThePersistedStatusAloneWhenTheUpgradeToreTheTunnelDown() {
        XCTAssertTrue(
            PlatformSDKMigrationDecision.shouldReconnectAfterCleanup(
                isNativeLive: false,
                isOnDemandArmed: false,
                lastKnownStatus: .connected
            )
        )
    }

    func testDoesNotReconnectWhenNothingSaysTheVPNWasUp() {
        XCTAssertFalse(
            PlatformSDKMigrationDecision.shouldReconnectAfterCleanup(
                isNativeLive: false,
                isOnDemandArmed: false,
                lastKnownStatus: .disconnected
            )
        )
    }

    func testDoesNotReconnectOnANonConnectedPersistedStatus() {
        for status: VPNStatus in [.disconnected, .connecting, .disconnecting, .unknown] {
            XCTAssertFalse(
                PlatformSDKMigrationDecision.shouldReconnectAfterCleanup(
                    isNativeLive: false,
                    isOnDemandArmed: false,
                    lastKnownStatus: status
                ),
                "\(status) is not evidence that the VPN was up"
            )
        }
    }

    // MARK: - shouldOweReconnectBeforeBootstrap

    func testOwesAReconnectWhenAPendingCleanupIsAboutToDeleteALiveTunnel() {
        XCTAssertTrue(
            PlatformSDKMigrationDecision.shouldOweReconnectBeforeBootstrap(
                usesPlatformSDKTunnel: true,
                didCleanup: false,
                hasStoredValue: false,
                lastKnownStatus: .connected
            )
        )
    }

    func testOwesAReconnectWhenAPreviousBuildCleanedUpWithoutRecordingAnAnswer() {
        XCTAssertTrue(
            PlatformSDKMigrationDecision.shouldOweReconnectBeforeBootstrap(
                usesPlatformSDKTunnel: true,
                didCleanup: true,
                hasStoredValue: false,
                lastKnownStatus: .connected
            )
        )
    }

    func testOwesNothingOnARecordedAnswer() {
        XCTAssertFalse(
            PlatformSDKMigrationDecision.shouldOweReconnectBeforeBootstrap(
                usesPlatformSDKTunnel: true,
                didCleanup: true,
                hasStoredValue: true,
                lastKnownStatus: .connected
            )
        )
    }

    func testOwesNothingWhenTheUserWasDisconnected() {
        XCTAssertFalse(
            PlatformSDKMigrationDecision.shouldOweReconnectBeforeBootstrap(
                usesPlatformSDKTunnel: true,
                didCleanup: false,
                hasStoredValue: false,
                lastKnownStatus: .disconnected
            )
        )
    }

    func testOwesNothingWhileStillOnTheLegacyProfiles() {
        XCTAssertFalse(
            PlatformSDKMigrationDecision.shouldOweReconnectBeforeBootstrap(
                usesPlatformSDKTunnel: false,
                didCleanup: false,
                hasStoredValue: false,
                lastKnownStatus: .connected
            )
        )
    }
}
