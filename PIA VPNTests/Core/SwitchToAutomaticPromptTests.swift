//
//  SwitchToAutomaticPromptTests.swift
//  PIA VPNTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import PIALibrary
import Testing
import UIKit

@testable import PIA_VPN

@Suite("SwitchToAutomaticPrompt guards")
struct SwitchToAutomaticPromptTests {

    private let sut = SwitchToAutomaticPrompt.shared
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    private func history(
        promptDates: [Date] = [],
        dismissCount: Int = 0,
        lastDismissedAt: Date? = nil,
        accepted: Bool = false
    ) -> AutoProtocolNudgeCaps.History {
        AutoProtocolNudgeCaps.History(
            promptDates: promptDates, dismissCount: dismissCount,
            lastDismissedAt: lastDismissedAt, accepted: accepted)
    }

    private func ago(_ days: TimeInterval) -> Date {
        now.addingTimeInterval(-days * 86_400)
    }

    private func shouldPresent(
        vpnType: String = KapePlatformSDKVPNType.wireGuard.rawValue,
        applicationState: UIApplication.State = .active,
        isPresenting: Bool = false,
        history overrides: AutoProtocolNudgeCaps.History? = nil
    ) -> Bool {
        sut.shouldPresent(
            vpnType: vpnType, applicationState: applicationState, isPresenting: isPresenting,
            history: overrides ?? history(), now: now)
    }

    @Test("A user pinned to a selectable protocol is offered the switch")
    func presentsWhenPinned() {
        #expect(shouldPresent(vpnType: KapePlatformSDKVPNType.wireGuard.rawValue, applicationState: .active, isPresenting: false))
        #expect(shouldPresent(vpnType: KapePlatformSDKVPNType.openVPN.rawValue, applicationState: .active, isPresenting: false))
    }

    @Test("A user already on Automatic is never offered the switch")
    func doesNotPresentOnAutomatic() {
        #expect(!shouldPresent(vpnType: KapePlatformSDKVPNType.automatic.rawValue, applicationState: .active, isPresenting: false))
    }

    @Test("Values that resolve to Automatic are treated as Automatic")
    func doesNotPresentForResolvedAutomatic() {
        // A legacy IKEv2 selection and anything unrecognised both behave as Automatic already.
        #expect(!shouldPresent(vpnType: KapePlatformSDKVPNType.iKEv2.rawValue, applicationState: .active, isPresenting: false))
        #expect(!shouldPresent(vpnType: "", applicationState: .active, isPresenting: false))
        #expect(!shouldPresent(vpnType: "NotAProtocol", applicationState: .active, isPresenting: false))
    }

    @Test("The prompt is dropped unless the app is foregrounded")
    func doesNotPresentWhenNotForegrounded() {
        #expect(!shouldPresent(applicationState: .background))
        #expect(!shouldPresent(applicationState: .inactive))
    }

    @Test("A second signal while the prompt is up does not stack another")
    func doesNotPresentWhileAlreadyShowing() {
        #expect(!shouldPresent(vpnType: KapePlatformSDKVPNType.wireGuard.rawValue, applicationState: .active, isPresenting: true))
    }

    @Test("A user who accepted is never prompted again")
    func acceptedIsNeverPromptedAgain() {
        #expect(!shouldPresent(history: history(accepted: true)))
    }

    @Test("Two dismissals stop the prompt permanently")
    func twoDismissalsStopIt() {
        #expect(!shouldPresent(history: history(dismissCount: 2, lastDismissedAt: ago(30))))
    }

    @Test("A dismissal starts a seven-day cooldown")
    func dismissalCooldown() {
        #expect(!shouldPresent(history: history(dismissCount: 1, lastDismissedAt: ago(3))))
        #expect(shouldPresent(history: history(dismissCount: 1, lastDismissedAt: ago(8))))
    }

    @Test("Three prompts is the lifetime cap")
    func lifetimeCap() {
        #expect(!shouldPresent(history: history(promptDates: [ago(300), ago(200), ago(100)])))
    }

    @Test("At most one prompt every fourteen days")
    func promptCapWindow() {
        #expect(!shouldPresent(history: history(promptDates: [ago(10)])))
        #expect(shouldPresent(history: history(promptDates: [ago(20)])))
    }

    @Test("The tunnel is re-applied only when a session is up")
    func reappliesTheTunnelOnlyWhenASessionIsUp() {
        #expect(sut.shouldReapplyTunnel(for: .connected))
        #expect(sut.shouldReapplyTunnel(for: .connecting))
        #expect(sut.shouldReapplyTunnel(for: .disconnecting))
        // Accepting while disconnected changes the preference without turning the VPN on.
        #expect(!sut.shouldReapplyTunnel(for: .disconnected))
        #expect(!sut.shouldReapplyTunnel(for: .unknown))
    }
}
