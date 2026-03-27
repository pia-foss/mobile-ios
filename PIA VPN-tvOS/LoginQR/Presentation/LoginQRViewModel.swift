//
//  LoginQRViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 4/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Combine
import Foundation
import PIALibrary

private let log = PIALogger.logger(for: LoginQRViewModel.self)

class LoginQRViewModel: ObservableObject {
    enum State {
        case expired
        case validating
        case loading
    }

    @Published var state: LoginQRViewModel.State = .loading
    @Published var qrCodeURL: URL?
    @Published var shouldShowErrorMessage = false
    @Published var expiresAt: String = ""
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    private var cancellable: Cancellable?
    private var expirationDate: Date?

    private let generateLoginQRCode: GenerateLoginQRCodeUseCaseType
    private let validateLoginQRCode: ValidateLoginQRCodeUseCaseType
    private let loginWithReceipt: LoginWithReceiptUseCaseType
    private let onSuccessAction: () -> Void
    private let onNavigateAction: () -> Void

    init(generateLoginQRCode: GenerateLoginQRCodeUseCaseType, validateLoginQRCode: ValidateLoginQRCodeUseCaseType, loginWithReceipt: LoginWithReceiptUseCaseType, onSuccessAction: @escaping () -> Void, onNavigateAction: @escaping () -> Void) {
        self.generateLoginQRCode = generateLoginQRCode
        self.validateLoginQRCode = validateLoginQRCode
        self.loginWithReceipt = loginWithReceipt
        self.onSuccessAction = onSuccessAction
        self.onNavigateAction = onNavigateAction
    }

    deinit {
        cancellable?.cancel()
    }

    func generateQRCode() {
        log.info("Generating QR code for login")
        state = .loading
        Task {
            do {
                let qrCode = try await generateLoginQRCode()
                log.info("QR code generated successfully")
                Task { @MainActor in
                    qrCodeURL = qrCode.url
                    expirationDate = qrCode.expiresAt
                    state = .validating
                    startTimer()
                }
                await validateQRCode(loginQRCode: qrCode)
            } catch {
                log.error("QR code generation failed: \(error.localizedDescription)")
                Task { @MainActor in
                    state = .validating
                    shouldShowErrorMessage = true
                }
            }
        }
    }

    func recoverPurchases() {
        log.info("Recovering purchases")
        state = .loading
        Task {
            do {
                let userAccount = try await loginWithReceipt()
                log.info("Purchase recovery succeeded")
                Task { @MainActor in
                    onSuccessAction()
                }
            } catch {
                log.error("Purchase recovery failed: \(error.localizedDescription)")
                Task { @MainActor in
                    state = .validating
                    shouldShowErrorMessage = true
                }
            }
        }
    }

    private func map(loginQRToken: LoginQRTokenDTO) -> LoginQRCode? {
        let dateString = loginQRToken.expiresAt
        let dateFormatter = ISO8601DateFormatter()

        guard let date = dateFormatter.date(from: dateString) else { return nil }

        return LoginQRCode(
            token: loginQRToken.token,
            expiresAt: date)
    }

    func navigateToRoute() {
        stopTimer()
        onNavigateAction()
    }

    private func validateQRCode(loginQRCode: LoginQRCode) async {
        log.info("Validating QR code login")
        do {
            try await validateLoginQRCode(qrCodeToken: loginQRCode)
            log.info("QR code login succeeded")
            Task { @MainActor in
                onSuccessAction()
            }

        } catch {
            log.error("QR code login validation failed: \(error.localizedDescription)")
            Task { @MainActor in
                state = .expired
                shouldShowErrorMessage = true
            }
        }
    }

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        cancellable = timer?.sink { [weak self] _ in
            self?.updateTimer()
        }
    }

    private func updateTimer() {
        guard let remaining = expirationDate?.timeIntervalSinceNow,
            remaining > 0
        else {
            stopTimer()
            return
        }

        expiresAt = formatTimeInterval(remaining)
    }

    private func stopTimer() {
        state = .expired
        cancellable?.cancel()
        timer = nil
        expiresAt = ""
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        return "\(totalSeconds / 60)m \(totalSeconds % 60)s"
    }
}
