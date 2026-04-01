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
    private let userAccountMapper: UserAccountMapper
    
    init(accountProvider: AccountProvider, userAccountMapper: UserAccountMapper) {
        self.accountProvider = accountProvider
        self.userAccountMapper = userAccountMapper
    }
    
    func login(with credentials: Credentials, completion: @escaping (Result<UserAccount, Error>) -> Void) {
        let pialibraryCredentials = PIALibrary.Credentials(username: credentials.username, password: credentials.password)
        let request = LoginRequest(credentials: pialibraryCredentials)
        
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
    
    private func handleLoginResult(userAccount: PIALibrary.UserAccount?, error: Error?, completion: @escaping (Result<UserAccount, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let userAccount = userAccount else {
            completion(.failure(ClientError.unexpectedReply))
            return
        }
        
        let user = userAccountMapper.map(userAccount: userAccount)
        
        guard userAccount.info?.isExpired == true else {
            completion(.success(user))
            return
        }
        
        completion(.failure(ClientError.expired))
    }
}
