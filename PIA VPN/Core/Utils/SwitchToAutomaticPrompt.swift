//
//  SwitchToAutomaticPrompt.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIALocalizations
import UIKit

private let log = PIALogger.logger(for: SwitchToAutomaticPrompt.self)

/// Offers the switch to Automatic when the tunnel reports that the pinned protocol keeps failing
/// The signal is a payload-less prod, so the prompt is dropped rather than queued when
/// it can't be shown; the tunnel re-posts on continued failure.
final class SwitchToAutomaticPrompt {

    static let shared = SwitchToAutomaticPrompt()

    // Weak: a tap outside the dialog dismisses it without running either handler.
    private weak var presentedPrompt: UIViewController?

    private init() {}

    func start() {
        PIATunnelSignal.startObserving()
        NotificationCenter.default.addObserver(self, selector: #selector(switchToAutomaticSuggested), name: PIATunnelSignal.switchToAutomaticSuggested.notificationName, object: nil)
    }

    func shouldPresent(
        vpnType: String, applicationState: UIApplication.State, isPresenting: Bool, history: AutoProtocolNudgeCaps.History, now: Date
    ) -> Bool {
        guard !isPresenting, applicationState == .active else {
            return false
        }

        guard SelectableVPNProtocol.resolved(fromStored: vpnType) != .automatic else {
            return false
        }

        return AutoProtocolNudgeCaps.allowsPrompt(history, now: now)
    }

    func shouldReapplyTunnel(for status: VPNStatus) -> Bool {
        switch status {
        case .connected, .connecting, .disconnecting:
            return true
        case .disconnected, .unknown:
            return false
        }
    }

    @objc private func switchToAutomaticSuggested() {
        let shouldPresent = shouldPresent(
            vpnType: Client.preferences.vpnType,
            applicationState: UIApplication.shared.applicationState,
            isPresenting: presentedPrompt?.presentingViewController != nil,
            history: AppPreferences.shared.autoProtocolNudgeHistory,
            now: Date()
        )

        guard shouldPresent, let presenter = AppDelegate.getRootTopViewController() else {
            return
        }

        let selected = SelectableVPNProtocol.resolved(fromStored: Client.preferences.vpnType)
        log.info("Offering the switch to Automatic from \(selected.rawValue)")

        AppPreferences.shared.recordAutoProtocolNudgeShown(at: Date())

        let alert = Macros.alert(L10n.AutoProtocolNudge.title, L10n.AutoProtocolNudge.message)
        alert.addCancelActionWithTitle(L10n.AutoProtocolNudge.dismiss) {
            log.info("Switch to Automatic dismissed")
            AppPreferences.shared.recordAutoProtocolNudgeDismissed(at: Date())
        }

        alert.addActionWithTitle(L10n.AutoProtocolNudge.confirm) { [weak self] in
            self?.switchToAutomatic()
        }

        presentedPrompt = alert
        presenter.present(alert, animated: true)
    }

    private func switchToAutomatic() {
        log.info("Switch to Automatic accepted")
        AppPreferences.shared.recordAutoProtocolNudgeAccepted()

        let preferences = Client.preferences.editable()
        preferences.vpnType = KapePlatformSDKVPNType.automatic.rawValue
        preferences.commit()

        Macros.postNotification(.ReloadSettings)

        guard shouldReapplyTunnel(for: Client.providers.vpnProvider.vpnStatus) else {
            return
        }

        // The tunnel reads the protocol from shared state, so this becomes an in-place session
        // restart on a live tunnel — no profile reinstall, no disconnect flash.
        Client.providers.vpnProvider.connect { error in
            if let error {
                log.error("Switch to Automatic failed to reconnect: \(error.localizedDescription)")
            }
        }
    }
}
