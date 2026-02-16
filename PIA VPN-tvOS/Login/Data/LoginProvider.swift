//
//  LoginProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 4/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class LoginProvider: LoginProviderType {
    private let accountProvider: AccountProvider

    init(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }
    
    func login(with credentials: Credentials, completion: @escaping (Result<UserAccount, Error>) -> Void) {
        let request = LoginRequest(credentials: credentials)

        accountProvider.login(with: request) { [weak self] userAccount, error in
            self?.handleLoginResult(userAccount: userAccount, error: error, completion: completion)
        }
    }
    
    func login(with receipt: Data, completion: @escaping (Result<UserAccount, Error>) -> Void) {
        let request = LoginReceiptRequest(receipt: receipt)
        
        accountProvider.login(with: request) { [weak self] userAccount, error in
            self?.handleLoginResult(userAccount: userAccount, error: error, completion: completion)
        }
    }


    private func handleLoginResult(userAccount: UserAccount?, error: Error?, completion: @escaping (Result<UserAccount, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let userAccount = userAccount else {
            completion(.failure(ClientError.unexpectedReply))
            return
        }

        guard userAccount.info?.isExpired == true else {
            completion(.success(userAccount))
            return
        }
        
        completion(.failure(ClientError.expired))
    }
}
