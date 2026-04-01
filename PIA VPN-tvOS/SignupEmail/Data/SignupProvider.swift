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
    private let errorMapper: SignupDomainErrorMapper
    
    init(accountProvider: AccountProvider, userAccountMapper: UserAccountMapper, store: InAppProvider, errorMapper: SignupDomainErrorMapper) {
        self.accountProvider = accountProvider
        self.userAccountMapper = userAccountMapper
        self.store = store
        self.errorMapper = errorMapper
    }
    
    func signup(email: String, transaction: InAppTransaction?, _ callback: @escaping (Result<UserAccount, SignupError>) -> Void) {
        let request = SignupRequest(email: email, transaction: transaction)
        
        guard store.paymentReceipt == nil else {
            signup(request: request, callback: callback)
            return
        }
        
        store.refreshPaymentReceipt { [weak self] error in
            self?.signup(request: request, callback: callback)
        }
    }
    
    private func signup(request: SignupRequest, callback: @escaping (Result<UserAccount, SignupError>) -> Void) {
        accountProvider.signup(with: request) { [weak self] (userAccount, error) in
            guard let self = self else { return }
            
            if let error = error {
                callback(.failure(errorMapper.map(error: error)))
                return
            }
            
            guard let userAccount = userAccount else {
                callback(.failure(errorMapper.map(error: ClientError.unexpectedReply)))
                return
            }
            
            let user = userAccountMapper.map(userAccount: userAccount)
            callback(.success(user))
        }
    }
}
