//
//  LoginWithCredentialsUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 27/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

private let log = PIALogger.logger(for: LoginWithCredentialsUseCase.self)

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
        let credentials = Credentials(
            username: username,
            password: password
        )

        log.info("Executing login with credentials")
        loginProvider.login(with: credentials) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let userAccount):
                    log.info("Login provider succeeded")
                    completion(.success(userAccount))
                case .failure(let error):
                    log.error("Login provider failed: \(error)")
                    completion(.failure(errorMapper.map(error: error)))
            }
        }
    }
}




