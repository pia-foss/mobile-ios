//
//  ValidateQRLoginUseCase.swift
//  PIA VPN
//
//  Created by Said Rehouni on 19/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol ValidateQRLoginUseCaseType {
    func callAsFunction(completion: @escaping (Result<Void, ClientError>) -> Void)
}

class ValidateQRLoginUseCase: ValidateQRLoginUseCaseType {
    private let apiToken: String
    private let tvOSBindToken: String
    private let loginProvider: LoginProviderType
    private let tokenProvider: TokenProvider
    
    init(apiToken: String, tvOSBindToken: String, loginProvider: LoginProviderType, tokenProvider: TokenProvider) {
        self.apiToken = apiToken
        self.tvOSBindToken = tvOSBindToken
        self.loginProvider = loginProvider
        self.tokenProvider = tokenProvider
    }
    
    func callAsFunction(completion: @escaping (Result<Void, ClientError>) -> Void) {
        loginProvider.bindTokens(apiToken: apiToken, loginToken: tvOSBindToken, completion: { [weak self] result in
            switch result {
                case .success:
                    self?.tokenProvider.removeTVOSToken()
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
            }
        })
    }
}
