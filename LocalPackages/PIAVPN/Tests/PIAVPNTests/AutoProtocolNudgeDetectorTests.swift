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

    private struct StubConfiguration: VpnConfiguration {
        let vpnProtocolName = "wireguard"
        let connectedEndpointSnapshot: PacketTunnelConnectedEndpoint?

        init(host: String?) {
            connectedEndpointSnapshot = host.map {
                PacketTunnelConnectedEndpoint(host: $0, port: 1337, protocolDescription: "WireGuard")
            }
        }

        #if DEBUG
            var endpointsCount: Int { 1 }
        #endif
    }

    /// Drives one analytics sink with a clock the test controls and a counter in place of the post.
    private final class Harness: @unchecked Sendable {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        private(set) var posts = 0
        private var offset: TimeInterval = 0
        private(set) var sut: AutoProtocolNudgeDetector!

        init(pinnedTo selectedProtocol: PIATunnelSharedState.TunnelProtocol = .wireGuard) {
            sut = AutoProtocolNudgeDetector(
                thresholds: .init(connectTimeout: 30, qualifyingAttempts: 6, minimumInterval: 180),
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

        func attempt(endpoint host: String?, failsAfter seconds: TimeInterval, error: PacketTunnelError = .connectionTimeout) {
            sut.attemptDidBegin(
                VpnAnalyticsAttemptBeginEvent(
                    sessionId: UUID(), connectionId: UUID(), attemptId: UUID(),
                    configuration: StubConfiguration(host: host),
                    selectedProtocol: "wireguard", selectedLocationDescription: nil))
            offset = seconds
            sut.attemptDidEnd(makeAttemptEnd(result: .failed(error)))
        }

        func attemptConnects(endpoint host: String?, after seconds: TimeInterval) {
            sut.attemptDidBegin(
                VpnAnalyticsAttemptBeginEvent(
                    sessionId: UUID(), connectionId: UUID(), attemptId: UUID(),
                    configuration: StubConfiguration(host: host),
                    selectedProtocol: "wireguard", selectedLocationDescription: nil))
            offset = seconds
            sut.attemptDidEnd(makeAttemptEnd(result: .connected))
        }

        private func makeAttemptEnd(result: PacketTunnelAttemptResult) -> VpnAnalyticsAttemptEndEvent {
            VpnAnalyticsAttemptEndEvent(
                attemptId: UUID(), result: result, endpoint: nil, elapsedMs: 0,
                selectedProtocol: "wireguard", selectedLocationDescription: nil)
        }
    }

    // MARK: - Batch wrap

    @Test("Re-dialling an endpoint already tried means the batch wrapped, and nudges")
    func batchWrapNudges() {
        let harness = Harness()
        harness.beginSession()
        for index in 0..<3 {
            harness.attempt(endpoint: "10.0.0.\(index)", failsAfter: 40)
        }
        #expect(harness.posts == 0)

        harness.attempt(endpoint: "10.0.0.0", failsAfter: 45)

        #expect(harness.posts == 1)
    }

    @Test("Without endpoint identity the attempt count is the fallback trigger")
    func attemptCountFallbackNudges() {
        let harness = Harness()
        harness.beginSession()

        for _ in 0..<5 {
            harness.attempt(endpoint: nil, failsAfter: 40)
        }
        #expect(harness.posts == 0)

        harness.attempt(endpoint: nil, failsAfter: 40)

        #expect(harness.posts == 1)
    }

    // MARK: - Eligibility

    @Test("A user already on Automatic is never nudged")
    func automaticIsNeverNudged() {
        let harness = Harness(pinnedTo: .automatic)
        harness.beginSession()

        for index in 0..<20 {
            harness.attempt(endpoint: "10.0.0.\(index % 3)", failsAfter: 600)
        }

        #expect(harness.posts == 0)
    }

    @Test("A batch that wraps before the connect timeout does not nudge yet")
    func dwellFloorIsRespected() {
        let harness = Harness()
        harness.beginSession()
        for index in 0..<3 {
            harness.attempt(endpoint: "10.0.0.\(index)", failsAfter: 5)
        }

        harness.attempt(endpoint: "10.0.0.0", failsAfter: 10)
        #expect(harness.posts == 0)

        harness.attempt(endpoint: "10.0.0.1", failsAfter: 31)
        #expect(harness.posts == 1)
    }

    @Test("Once a session connects it stops nudging, even if it later fails")
    func connectingStopsTheNudge() {
        let harness = Harness()
        harness.beginSession()
        for index in 0..<3 {
            harness.attempt(endpoint: "10.0.0.\(index)", failsAfter: 40)
        }

        harness.attemptConnects(endpoint: "10.0.0.9", after: 50)

        for index in 0..<10 {
            harness.attempt(endpoint: "10.0.1.\(index)", failsAfter: 300)
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
            for index in 0..<20 {
                harness.attempt(endpoint: "10.0.0.\(index % 3)", failsAfter: 600, error: error)
            }
            #expect(harness.posts == 0, "\(error) must not nudge")
        }
    }

    @Test("Excluded failures mixed into a run do not inflate the count")
    func excludedReasonsDoNotCount() {
        let harness = Harness()
        harness.beginSession()

        for _ in 0..<5 {
            harness.attempt(endpoint: nil, failsAfter: 40, error: .authenticationFailed(underlyingError: nil))
        }
        #expect(harness.posts == 0)

        for _ in 0..<5 {
            harness.attempt(endpoint: nil, failsAfter: 40)
        }
        #expect(harness.posts == 0)

        harness.attempt(endpoint: nil, failsAfter: 40)
        #expect(harness.posts == 1)
    }

    @Test("A cancelled attempt is not a failure")
    func cancelledAttemptsDoNotCount() {
        let harness = Harness()
        harness.beginSession()
        for index in 0..<3 {
            harness.attempt(endpoint: "10.0.0.\(index)", failsAfter: 40)
        }

        harness.sut.attemptDidEnd(
            VpnAnalyticsAttemptEndEvent(
                attemptId: UUID(), result: .cancelled, endpoint: nil, elapsedMs: 0,
                selectedProtocol: "wireguard", selectedLocationDescription: nil))

        #expect(harness.posts == 0)
    }

    // MARK: - Repeat posting

    @Test("A failing session does not re-post inside the minimum interval")
    func doesNotRepostTooSoon() {
        let harness = Harness()
        harness.beginSession()
        for index in 0..<3 {
            harness.attempt(endpoint: "10.0.0.\(index)", failsAfter: 40)
        }
        harness.attempt(endpoint: "10.0.0.0", failsAfter: 45)
        #expect(harness.posts == 1)

        harness.attempt(endpoint: "10.0.0.1", failsAfter: 100)

        #expect(harness.posts == 1)
    }

    @Test("A session still failing past the minimum interval posts again")
    func repostsAfterTheInterval() {
        let harness = Harness()
        harness.beginSession()
        for index in 0..<3 {
            harness.attempt(endpoint: "10.0.0.\(index)", failsAfter: 40)
        }
        harness.attempt(endpoint: "10.0.0.0", failsAfter: 45)

        harness.attempt(endpoint: "10.0.0.1", failsAfter: 226)

        #expect(harness.posts == 2)
    }

    @Test("A new session starts from a clean slate")
    func sessionResets() {
        let harness = Harness()
        harness.beginSession()
        for index in 0..<3 {
            harness.attempt(endpoint: "10.0.0.\(index)", failsAfter: 40)
        }
        harness.attempt(endpoint: "10.0.0.0", failsAfter: 45)
        #expect(harness.posts == 1)

        harness.beginSession(at: 600)
        harness.attempt(endpoint: "10.0.0.0", failsAfter: 605)

        #expect(harness.posts == 1)
    }
}
