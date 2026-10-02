//
//  AutoProtocolNudgeDetectorTests.swift
//  PIAVPN
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

import Foundation
import KapeVPN_PacketTunnel
import PIALibrary
import Testing

@testable import PIAVPN

@Suite("AutoProtocolNudgeDetector")
struct AutoProtocolNudgeDetectorTests {

    private static let hour: TimeInterval = 3_600

    /// Drives one analytics sink with a clock the test controls and a counter in place of the post.
    private final class Harness: @unchecked Sendable {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        private(set) var posts = 0
        private var offset: TimeInterval = 0
        private(set) var sut: AutoProtocolNudgeDetector!

        init(pinnedTo selectedProtocol: PIATunnelSharedState.TunnelProtocol = .wireGuard) {
            sut = AutoProtocolNudgeDetector(
                thresholds: .init(
                    connectTimeout: 30, shortFailureWindow: 600, shortFailureWindowCount: 2,
                    longFailureWindow: 86_400, longFailureWindowCount: 3, minimumInterval: 180),
                selectedProtocol: { selectedProtocol },
                now: { [unowned self] in start.addingTimeInterval(offset) },
                post: { [unowned self] in posts += 1 }
            )
        }

        func beginSession(at seconds: TimeInterval = 0) {
            offset = seconds
            sut.sessionDidBegin(
                VpnAnalyticsSessionBeginEvent(
                    sessionId: UUID(), selectedProtocol: "wireguard", selectedLocationDescription: nil))
        }

        func attemptFails(at seconds: TimeInterval, error: PacketTunnelError = .connectionTimeout) {
            offset = seconds
            sut.attemptDidEnd(makeAttemptEnd(result: .failed(error)))
        }

        func attemptConnects(at seconds: TimeInterval) {
            offset = seconds
            sut.attemptDidEnd(makeAttemptEnd(result: .connected))
        }

        func attemptIsCancelled(at seconds: TimeInterval) {
            offset = seconds
            sut.attemptDidEnd(makeAttemptEnd(result: .cancelled))
        }

        /// One session that fails for a single connect timeout, i.e. one qualifying failure.
        func failedSession(at seconds: TimeInterval) {
            beginSession(at: seconds)
            attemptFails(at: seconds + 31)
        }

        private func makeAttemptEnd(result: PacketTunnelAttemptResult) -> VpnAnalyticsAttemptEndEvent {
            VpnAnalyticsAttemptEndEvent(
                attemptId: UUID(), result: result, endpoint: nil, elapsedMs: 0,
                selectedProtocol: "wireguard", selectedLocationDescription: nil)
        }
    }

    // MARK: - Counting

    @Test("Failures inside the first connect timeout do not count")
    func failuresBeforeTheTimeoutDoNotCount() {
        let harness = Harness()
        harness.beginSession()

        for second in stride(from: 1.0, through: 29, by: 4) {
            harness.attemptFails(at: second)
        }
        harness.attemptFails(at: 31)

        #expect(harness.posts == 0)
    }

    @Test("Each connect timeout spent failing counts once, however many attempts fail in it")
    func oneFailurePerConnectTimeout() {
        let harness = Harness()
        harness.beginSession()

        harness.attemptFails(at: 31)
        harness.attemptFails(at: 40)
        harness.attemptFails(at: 55)
        #expect(harness.posts == 0)

        harness.attemptFails(at: 62)
        #expect(harness.posts == 1)
    }

    // MARK: - Trigger

    @Test("One qualifying failure alone does not nudge")
    func oneFailureDoesNotNudge() {
        let harness = Harness()
        harness.failedSession(at: 0)

        #expect(harness.posts == 0)
    }

    @Test("A session stuck for two connect timeouts nudges")
    func stuckSessionNudges() {
        let harness = Harness()
        harness.beginSession()

        harness.attemptFails(at: 31)
        #expect(harness.posts == 0)

        harness.attemptFails(at: 62)
        #expect(harness.posts == 1)
    }

    @Test("Two failed sessions within 10 minutes nudge")
    func twoFailuresInTheShortWindowNudge() {
        let harness = Harness()
        harness.failedSession(at: 0)
        #expect(harness.posts == 0)

        harness.failedSession(at: 300)

        #expect(harness.posts == 1)
    }

    @Test("Two failed sessions more than 10 minutes apart do not nudge")
    func twoFailuresOutsideTheShortWindowDoNotNudge() {
        let harness = Harness()
        harness.failedSession(at: 0)
        harness.failedSession(at: Self.hour)

        #expect(harness.posts == 0)
    }

    @Test("Three failed sessions within 24 hours nudge")
    func threeFailuresInTheLongWindowNudge() {
        let harness = Harness()
        harness.failedSession(at: 0)
        harness.failedSession(at: 2 * Self.hour)
        #expect(harness.posts == 0)

        harness.failedSession(at: 5 * Self.hour)

        #expect(harness.posts == 1)
    }

    @Test("Failures older than 24 hours are dropped and do not count")
    func failuresOutsideTheLongWindowAreDropped() {
        let harness = Harness()
        harness.failedSession(at: 0)
        harness.failedSession(at: 2 * Self.hour)
        harness.failedSession(at: 25 * Self.hour)

        #expect(harness.posts == 0)
    }

    // MARK: - Eligibility

    @Test("A user already on Automatic is never nudged")
    func automaticIsNeverNudged() {
        let harness = Harness(pinnedTo: .automatic)
        harness.beginSession()

        for second in stride(from: 31.0, through: 600, by: 31) {
            harness.attemptFails(at: second)
        }

        #expect(harness.posts == 0)
    }

    @Test("Once a session connects it stops counting, even if it later fails")
    func connectingStopsTheNudge() {
        let harness = Harness()
        harness.beginSession()
        harness.attemptFails(at: 31)

        harness.attemptConnects(at: 40)

        for second in stride(from: 70.0, through: 600, by: 31) {
            harness.attemptFails(at: second)
        }
        #expect(harness.posts == 0)
    }

    // MARK: - Exclusions

    @Test("Reasons a protocol switch cannot fix never nudge and never count")
    func excludedReasonsNeverNudge() {
        let excluded: [PacketTunnelError] = [
            .authenticationFailed(underlyingError: nil), .noEndpointsAvailable, .endpointsExcludedByLicense,
            .unsupportedProtocol, .dipExpired, .dipUnderMaintenance, .dipUnavailable, .dipNotEntitled
        ]

        for error in excluded {
            let harness = Harness()
            harness.beginSession()
            for second in stride(from: 31.0, through: 600, by: 31) {
                harness.attemptFails(at: second, error: error)
            }
            #expect(harness.posts == 0, "\(error) must not nudge")

            harness.attemptFails(at: 631)
            #expect(harness.posts == 0, "\(error) must not count")
        }
    }

    @Test("A cancelled attempt is not a failure")
    func cancelledAttemptsDoNotCount() {
        let harness = Harness()
        harness.beginSession()

        harness.attemptIsCancelled(at: 31)
        harness.attemptIsCancelled(at: 62)
        harness.attemptFails(at: 93)

        #expect(harness.posts == 0)
    }

    // MARK: - Repeat posting

    @Test("A failing session does not re-post inside the minimum interval")
    func doesNotRepostTooSoon() {
        let harness = Harness()
        harness.beginSession()
        harness.attemptFails(at: 31)
        harness.attemptFails(at: 62)
        #expect(harness.posts == 1)

        harness.attemptFails(at: 100)
        harness.attemptFails(at: 200)

        #expect(harness.posts == 1)
    }

    @Test("A session still failing past the minimum interval posts again")
    func repostsAfterTheInterval() {
        let harness = Harness()
        harness.beginSession()
        harness.attemptFails(at: 31)
        harness.attemptFails(at: 62)

        harness.attemptFails(at: 243)

        #expect(harness.posts == 2)
    }

    @Test("A new session in the same tunnel keeps earlier failures but restarts its own connect timeout")
    func newSessionKeepsTheLog() {
        let harness = Harness()
        harness.failedSession(at: 0)

        harness.beginSession(at: 60)
        harness.attemptFails(at: 70)
        #expect(harness.posts == 0)

        harness.attemptFails(at: 91)
        #expect(harness.posts == 1)
    }
}
