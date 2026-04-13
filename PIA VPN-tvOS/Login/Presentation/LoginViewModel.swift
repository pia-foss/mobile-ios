//
//  LoginViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 23/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

private let log = PIALogger.logger(for: LoginViewModel.self)

class LoginViewModel: ObservableObject {
    private let loginWithCredentialsUseCase: LoginWithCredentialsUseCaseType
    private let checkLoginAvailability: CheckLoginAvailabilityType
    private let validateLoginCredentials: ValidateCredentialsFormatType
    private let errorHandler: LoginViewModelErrorHandlerType
    private let onSuccessAction: AppRouter.Actions
    private let onExpiredAction: AppRouter.Actions

    @Published var isAccountExpired = false
    @Published var shouldShowErrorMessage = false
    @Published var loginStatus: LoginStatus = .none

    init(loginWithCredentialsUseCase: LoginWithCredentialsUseCaseType, checkLoginAvailability: CheckLoginAvailabilityType, validateLoginCredentials: ValidateCredentialsFormatType, errorHandler: LoginViewModelErrorHandlerType, onSuccessAction: AppRouter.Actions, onExpiredAction: AppRouter.Actions) {
        self.loginWithCredentialsUseCase = loginWithCredentialsUseCase
        self.checkLoginAvailability = checkLoginAvailability
        self.validateLoginCredentials = validateLoginCredentials
        self.errorHandler = errorHandler
        self.onSuccessAction = onSuccessAction
        self.onExpiredAction = onExpiredAction
    }

    func login(username: String, password: String) {
        if case .isLogging = loginStatus {
            return
        }

        if case .failure(let error) = checkLoginAvailability() {
            log.error("Login unavailable: \(error)")
            handleError(error)
            return
        }

        if case .failure(let error) = validateLoginCredentials(username: username, password: password) {
            log.error("Login credentials validation failed: \(error)")
            handleError(error)
            return
        }

        log.info("Login requested")
        loginStatus = .isLogging

        loginWithCredentialsUseCase.execute(username: username, password: password) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let userAccount):
                log.info("Login succeeded")
                Task { @MainActor in
                    self.loginStatus = .succeeded(userAccount: userAccount)
                    self.onSuccessAction()
                }

            case .failure(let error):
                log.error("Login failed: \(error)")
                handleError(error)
            }
        }
    }

    private func handleError(_ error: LoginError) {
        guard error != .expired else {
            log.error("Login failed: account expired")
            Task { @MainActor in
                loginStatus = .failed(errorMessage: nil, field: .none)
                isAccountExpired = true
                onExpiredAction()
            }
            return
        }

        if case .throttled(let delay) = error {
            log.error("Login throttled for \(delay)s")
            checkLoginAvailability.disableLoginFor(delay)
        }

        Task { @MainActor in
            loginStatus = errorHandler(error: error)
            shouldShowErrorMessage = true
        }
    }
}
