//
//  LoginViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 23/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

enum LoginStatus {
    case none
    case isLogging
    case failed(error: LoginError)
    case succeeded(userAccount: UserAccount)
}

class LoginViewModel: ObservableObject {
    private let loginWithCredentialsUseCase: LoginWithCredentialsUseCaseType
    private let checkLoginAvailability: CheckLoginAvailabilityType
    private let validateLoginCredentials: ValidateCredentialsFormatType
    private let errorMapper: LoginPresentableErrorMapper
    
    var loginStatus: LoginStatus = .none
    
    init(loginWithCredentialsUseCase: LoginWithCredentialsUseCaseType, checkLoginAvailability: CheckLoginAvailabilityType, validateLoginCredentials: ValidateCredentialsFormatType, errorMapper: LoginPresentableErrorMapper) {
        self.loginWithCredentialsUseCase = loginWithCredentialsUseCase
        self.checkLoginAvailability = checkLoginAvailability
        self.validateLoginCredentials = validateLoginCredentials
        self.errorMapper = errorMapper
    }
    
    func login(username: String, password: String) async {
        if case .isLogging = loginStatus {
            return
        }
        
        if case .failure(let error) = checkLoginAvailability() {
            handleError(error: error)
            return
        }
        
        if case .failure(let error) = validateLoginCredentials(username: username, password: password) {
            // Handle credentials wrong format
            loginStatus = .failed(error: error)
            return
        }
        
        loginStatus = .isLogging
        
        await withCheckedContinuation { continuation in
            loginWithCredentialsUseCase.execute(username: username, password: password) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                    case .success(let userAccount):
                        self.loginStatus = .succeeded(userAccount: userAccount)
                    
                    case .failure(let error):
                        self.handleError(error: error)
                }
                continuation.resume()
            }
        }
    }
    
    private func handleError(error: LoginError) {
        if case .throttled(let delay) = error {
            checkLoginAvailability.disableLoginFor(delay)
        }
        
        let errorMessage = errorMapper.map(error: error)
        loginStatus = .failed(error: error)
    }
}
