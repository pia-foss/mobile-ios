//
//  SignupProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 27/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class SignupProvider: SignupProviderType {
    private let accountProvider: AccountProvider
    private let userAccountMapper: UserAccountMapper
    private let store: InAppProvider
    
    init(accountProvider: AccountProvider, userAccountMapper: UserAccountMapper, store: InAppProvider) {
        self.accountProvider = accountProvider
        self.userAccountMapper = userAccountMapper
        self.store = store
    }
    
    func signup(email: String, transaction: InAppTransaction?, _ callback: @escaping (Result<UserAccount, Error>) -> Void) {
        let request = SignupRequest(email: email, transaction: transaction)
        
        guard store.paymentReceipt == nil else {
            signup(request: request, callback: callback)
            return
        }
        
        store.refreshPaymentReceipt { [weak self] error in
            self?.signup(request: request, callback: callback)
        }
    }
    
    private func signup(request: SignupRequest, callback: @escaping (Result<UserAccount, Error>) -> Void) {
        accountProvider.signup(with: request) { [weak self] (userAccount, error) in
            guard let self = self else { return }
            
            if let error = error {
                callback(.failure(error))
                return
            }
            
            guard let userAccount = userAccount else {
                callback(.failure(ClientError.unexpectedReply))
                return
            }
            
            let user = userAccountMapper.map(userAccount: userAccount)
            callback(.success(user))
        }
    }
}
