//
//  WelcomeBackViewModel.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

private let log = PIALogger.logger(for: WelcomeBackViewModel.self)

/// Offered over the signup paywall when this Apple ID already holds a live subscription, so a
/// returning customer signs in to the account they pay for instead of buying a second one.
///
/// Follows the rules of the iOS screen (`WelcomeBack.Reducer` in PIAPaywall): taps are ignored
/// while the receipt sign-in runs, and a failed sign-in quietly hands the customer back to the paywall.
@MainActor
final class WelcomeBackViewModel: ObservableObject {
    @Published private(set) var isRestoring = false

    private let loginWithCurrentReceipt: LoginWithCurrentReceiptUseCaseType
    private let onSuccessAction: () -> Void
    private let onRequestLoginAction: () -> Void
    private let onDismissAction: () -> Void

    init(
        loginWithCurrentReceipt: LoginWithCurrentReceiptUseCaseType,
        onSuccessAction: @escaping () -> Void,
        onRequestLoginAction: @escaping () -> Void,
        onDismissAction: @escaping () -> Void
    ) {
        self.loginWithCurrentReceipt = loginWithCurrentReceipt
        self.onSuccessAction = onSuccessAction
        self.onRequestLoginAction = onRequestLoginAction
        self.onDismissAction = onDismissAction
    }

    func appStoreAccountTapped() {
        guard !isRestoring else { return }
        isRestoring = true
        Task { await restore() }
    }

    func usernameAndPasswordTapped() {
        guard !isRestoring else { return }
        onRequestLoginAction()
    }

    private func restore() async {
        do {
            _ = try await loginWithCurrentReceipt()
            log.info("Welcome back: signed in with the subscription receipt")
            isRestoring = false
            onSuccessAction()
        } catch {
            log.error("Welcome back: receipt sign-in failed: \(error)")
            isRestoring = false
            onDismissAction()
        }
    }
}
