//
//  LoginWithCredentialsUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 27/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol LoginWithCredentialsUseCaseType {
    func execute(username: String, password: String, completion: @escaping (Result<UserAccount, LoginError>) -> Void)
}

class LoginWithCredentialsUseCase: LoginWithCredentialsUseCaseType {
    private let loginProvider: LoginProviderType
    private let errorMapper: LoginDomainErrorMapperType
    
    init(loginProvider: LoginProviderType, errorMapper: LoginDomainErrorMapperType) {
        self.loginProvider = loginProvider
        self.errorMapper = errorMapper
    }
    
    func execute(username: String, password: String, completion: @escaping (Result<UserAccount, LoginError>) -> Void) {
        let credentials = Credentials(username: username, 
                                      password: password)
        let request = LoginRequest(credentials: credentials)
        
        loginProvider.login(with: request) { [weak self] userAccount, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(errorMapper.map(error: error)))
                return
            }
            
            guard let userAccount = userAccount else {
                completion(.failure(.generic(message: nil)))
                return
            }
            
            completion(.success(userAccount))
        }
    }
}




