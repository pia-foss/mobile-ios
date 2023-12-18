//
//  LoginViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 23/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

class LoginViewModel: ObservableObject {
    private let loginWithCredentialsUseCase: LoginWithCredentialsUseCaseType
    private let checkLoginAvailability: CheckLoginAvailabilityType
    private let validateLoginCredentials: ValidateCredentialsFormatType
    private let errorHandler: LoginViewModelErrorHandlerType
    
    @Published var isAccountExpired = false
    @Published var didLoginSuccessfully = false
    @Published var shouldShowErrorMessage = false
    @Published var loginStatus: LoginStatus = .none
    
    init(loginWithCredentialsUseCase: LoginWithCredentialsUseCaseType, checkLoginAvailability: CheckLoginAvailabilityType, validateLoginCredentials: ValidateCredentialsFormatType, errorHandler: LoginViewModelErrorHandlerType) {
        self.loginWithCredentialsUseCase = loginWithCredentialsUseCase
        self.checkLoginAvailability = checkLoginAvailability
        self.validateLoginCredentials = validateLoginCredentials
        self.errorHandler = errorHandler
    }
    
    func login(username: String, password: String) {
        if case .isLogging = loginStatus {
            return
        }
        
        if case .failure(let error) = checkLoginAvailability() {
            handleError(error)
            return
        }
        
        if case .failure(let error) = validateLoginCredentials(username: username, password: password) {
            handleError(error)
            return
        }
        
        loginStatus = .isLogging
        
        loginWithCredentialsUseCase.execute(username: username, password: password) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let userAccount):
                    Task { @MainActor in
                        self.loginStatus = .succeeded(userAccount: userAccount)
                        self.didLoginSuccessfully = true
                    }
                    
                case .failure(let error):
                    handleError(error)
            }
        }
    }
    
    private func handleError(_ error: LoginError) {
        guard error != .expired else {
            Task { @MainActor in
                loginStatus = .failed(errorMessage: nil, field: .none)
                isAccountExpired = true
            }
            return
        }
        
        if case .throttled(let delay) = error {
            checkLoginAvailability.disableLoginFor(delay)
        }
        
        Task { @MainActor in
            loginStatus = errorHandler(error: error)
            shouldShowErrorMessage = true
        }
    }
}
