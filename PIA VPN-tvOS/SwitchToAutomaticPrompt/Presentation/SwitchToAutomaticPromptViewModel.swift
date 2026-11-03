//
//  SwitchToAutomaticPromptViewModel.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Combine
import Foundation
import PIALibrary
import PIALocalizations

private let log = PIALogger.logger(for: SwitchToAutomaticPromptViewModel.self)

/// Offers the switch to Automatic when the tunnel reports that the pinned protocol keeps failing.
/// The signal is a payload-less prod, so the prompt is dropped rather than queued when it can't be
/// shown; the tunnel re-posts on continued failure.
@MainActor
final class SwitchToAutomaticPromptViewModel: ObservableObject {

    @Published var isPresented = false

    let title = L10n.AutoProtocolNudge.title
    let message = L10n.AutoProtocolNudge.message
    let acceptTitle = L10n.AutoProtocolNudge.confirm
    let dismissTitle = L10n.AutoProtocolNudge.dismiss

    private let protocolSelection: ProtocolSelectionUseCaseType
    private let nudgeHistory: () -> AutoProtocolNudgeCaps.History
    private var isForegrounded = false
    private var cancellables = Set<AnyCancellable>()

    init(
        protocolSelection: ProtocolSelectionUseCaseType,
        notificationCenter: NotificationCenterType = NotificationCenter.default,
        nudgeHistory: @escaping () -> AutoProtocolNudgeCaps.History = {
            AppPreferences.shared.autoProtocolNudgeHistory
        }
    ) {
        self.protocolSelection = protocolSelection
        self.nudgeHistory = nudgeHistory

        PIATunnelSignal.startObserving()

        notificationCenter
            .publisher(for: PIATunnelSignal.switchToAutomaticSuggested.notificationName, object: nil)
            .sink { [weak self] _ in self?.switchToAutomaticSuggested() }
            .store(in: &cancellables)
    }

    func sceneDidBecomeActive() {
        isForegrounded = true
    }

    func sceneDidBecomeInactive() {
        isForegrounded = false
    }

    func switchToAutomaticWasTapped() {
        log.info("Switch to Automatic accepted")
        AppPreferences.shared.recordAutoProtocolNudgeAccepted()
        protocolSelection.select(.automatic)
    }

    func promptWasDismissed() {
        log.info("Switch to Automatic dismissed")
        AppPreferences.shared.recordAutoProtocolNudgeDismissed(at: Date())
    }

    private func switchToAutomaticSuggested() {
        guard
            isForegrounded,
            !isPresented,
            protocolSelection.selectedProtocol() != .automatic,
            AutoProtocolNudgeCaps.allowsPrompt(nudgeHistory(), now: Date())
        else {
            return
        }

        AppPreferences.shared.recordAutoProtocolNudgeShown(at: Date())

        log.info("Offering the switch to Automatic from \(protocolSelection.selectedProtocol().rawValue)")
        isPresented = true
    }
}
