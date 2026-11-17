//
//  AutoProtocolNudgeDetector.swift
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

/// Watches the SDK's connection events and, once a user pinned to one protocol keeps failing to
/// connect, posts the signal that offers them Automatic.
///
/// The SDK reports no terminal failure for this case — a pinned protocol that never connects produces
/// an unbounded stream of failed attempts — so every `connectTimeout` a session spends failing without
/// connecting counts as one qualifying failure. The nudge fires on 2 within `shortFailureWindow` or 3
/// within `longFailureWindow`, matching Android's `ConnectionProblemDetector`. Failures are kept in
/// memory, so they span in-place session restarts but not a new tunnel process.
///
/// The SDK calls these on its own serial queue, so state is held under a mutex. The per-attempt
/// callbacks stay cheap — no file I/O, no waiting; only the once-per-session `sessionDidBegin` reads
/// the shared-state file, to pick up the protocol selected when the session began.
final class AutoProtocolNudgeDetector: VpnConnectionAnalytics {

    struct Thresholds: Sendable {
        let connectTimeout: TimeInterval
        let shortFailureWindow: TimeInterval
        let shortFailureWindowCount: Int
        let longFailureWindow: TimeInterval
        let longFailureWindowCount: Int
        let minimumInterval: TimeInterval

        init(
            connectTimeout: TimeInterval = AppConstants.AutoProtocolNudge.connectTimeout,
            shortFailureWindow: TimeInterval = AppConstants.AutoProtocolNudge.shortFailureWindow,
            shortFailureWindowCount: Int = AppConstants.AutoProtocolNudge.shortFailureWindowCount,
            longFailureWindow: TimeInterval = AppConstants.AutoProtocolNudge.longFailureWindow,
            longFailureWindowCount: Int = AppConstants.AutoProtocolNudge.longFailureWindowCount,
            minimumInterval: TimeInterval = AppConstants.AutoProtocolNudge.minimumInterval
        ) {
            self.connectTimeout = connectTimeout
            self.shortFailureWindow = shortFailureWindow
            self.shortFailureWindowCount = shortFailureWindowCount
            self.longFailureWindow = longFailureWindow
            self.longFailureWindowCount = longFailureWindowCount
            self.minimumInterval = minimumInterval
        }
    }

    private struct SessionState {
        var selectedProtocol: PIATunnelSharedState.TunnelProtocol = .automatic
        var nextFailureAt: Date?
        var hasConnected = false
        var lastPostedAt: Date?
        var failures: [Date] = []
    }

    private let thresholds: Thresholds
    private let selectedProtocol: @Sendable () -> PIATunnelSharedState.TunnelProtocol
    private let now: @Sendable () -> Date
    private let post: @Sendable () -> Void
    private let sessionState = Mutex(SessionState())
    private let logger = PIATunnelLogger(label: "AutoProtocolNudgeDetector")

    init(
        thresholds: Thresholds = Thresholds(),
        selectedProtocol: @escaping @Sendable () -> PIATunnelSharedState.TunnelProtocol = {
            PIATunnelSharedState.readConfig().selectedProtocol
        },
        now: @escaping @Sendable () -> Date = {
            Date()
        },
        post: @escaping @Sendable () -> Void = {
            PIATunnelSignal.switchToAutomaticSuggested.post()
        }
    ) {
        self.thresholds = thresholds
        self.selectedProtocol = selectedProtocol
        self.now = now
        self.post = post
    }

    // MARK: - VpnConnectionAnalytics

    func sessionDidBegin(_ event: VpnAnalyticsSessionBeginEvent) {
        // Read the user's choice from shared state rather than the event: it is authoritative and is
        // re-read on an in-place protocol switch.
        let selected = selectedProtocol()
        let nextFailureAt = now().addingTimeInterval(thresholds.connectTimeout)
        sessionState.withLock { state in
            state = SessionState(selectedProtocol: selected, nextFailureAt: nextFailureAt, failures: state.failures)
        }
    }

    func sessionDidEnd(_ event: VpnAnalyticsSessionEndEvent) {}

    func connectionDidBegin(_ event: VpnAnalyticsConnectionBeginEvent) {}

    func connectionDidEnd(_ event: VpnAnalyticsConnectionEndEvent) {}

    func attemptDidBegin(_ event: VpnAnalyticsAttemptBeginEvent) {}

    func attemptDidEnd(_ event: VpnAnalyticsAttemptEndEvent) {
        switch event.result {
        case .connected:
            sessionState.withLock { state in
                state.hasConnected = true
            }

        case .cancelled:
            break

        case .failed(let error):
            guard
                error.suggestsProtocolChange,
                recordFailure(at: now())
            else {
                return
            }

            logger.info("Suggesting the switch to Automatic after repeated failures: \(error)")
            post()
        }
    }

    // MARK: - Decision

    private func recordFailure(at date: Date) -> Bool {
        sessionState.withLock { state in
            guard
                state.selectedProtocol != .automatic,
                !state.hasConnected,
                let nextFailureAt = state.nextFailureAt,
                date >= nextFailureAt
            else {
                return false
            }

            state.nextFailureAt = date.addingTimeInterval(thresholds.connectTimeout)

            state.failures = state.failures.filter { date.timeIntervalSince($0) < thresholds.longFailureWindow } + [date]

            let shortWindowFailures = state.failures.filter { date.timeIntervalSince($0) < thresholds.shortFailureWindow }
            guard shortWindowFailures.count >= thresholds.shortFailureWindowCount || state.failures.count >= thresholds.longFailureWindowCount else {
                return false
            }

            if let lastPostedAt = state.lastPostedAt, date.timeIntervalSince(lastPostedAt) < thresholds.minimumInterval {
                return false
            }

            state.lastPostedAt = date
            return true
        }
    }
}

extension PacketTunnelError {
    /// Whether a different protocol could plausibly fix this. Auth, DIP, licensing and server-list
    /// problems follow the user to every protocol, so they must never nudge.
    var suggestsProtocolChange: Bool {
        switch self {
        case .connectionTimeout, .connectFailed, .setupFailed:
            return true
        case .authenticationFailed, .noEndpointsAvailable, .endpointsExcludedByLicense,
            .unsupportedProtocol, .dipExpired, .dipUnderMaintenance, .dipUnavailable, .dipNotEntitled:
            return false
        @unknown default:
            return false
        }
    }
}
