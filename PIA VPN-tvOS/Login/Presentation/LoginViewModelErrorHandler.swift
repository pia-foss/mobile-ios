//
//  LoginViewModelErrorHandler.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 13/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol LoginViewModelErrorHandlerType {
    func callAsFunction(error: LoginError) -> LoginStatus
}

class LoginViewModelErrorHandler: LoginViewModelErrorHandlerType {
    private let errorMapper: LoginPresentableErrorMapper
    
    init(errorMapper: LoginPresentableErrorMapper) {
        self.errorMapper = errorMapper
    }
    
    func callAsFunction(error: LoginError) -> LoginStatus {
        guard error != .usernameWrongFormat && error != .passwordWrongFormat else {
            return handleCredentialsError(error)
        }
        
        let message = errorMapper.map(error: error)
        return .failed(errorMessage: message, field: .none)
    }
    
    private func handleCredentialsError(_ error: LoginError) -> LoginStatus {
        let message = errorMapper.map(error: error)
        let field: LoginCredentialsError = error == .usernameWrongFormat ? .username : .password
        
        return .failed(errorMessage: message, field: field)
    }
}
