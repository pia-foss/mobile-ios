//
//  LoginProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 4/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIABase

final class LoginProvider: LoginProviderType {
    private let accountProvider: AccountProvider

    init(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }

    func login(with credentials: Credentials, completion: @escaping ClientCallback<UserAccount>) {
        let request = LoginRequest(credentials: credentials)

        accountProvider.login(with: request) { [weak self] result in
            self?.handleLoginResult(result: result, completion: completion)
        }
    }

    func login(with receipt: JWS, completion: @escaping ClientCallback<UserAccount>) {
        let request = LoginReceiptRequest(receipt: receipt)

        accountProvider.login(with: request) { [weak self] result in
            self?.handleLoginResult(result: result, completion: completion)
        }
    }

    private func handleLoginResult(
        result: ClientResult<UserAccount>,
        completion: @escaping ClientCallback<UserAccount>
    ) {
        switch result {
        case .failure(let error):
            completion(.failure(error))

        case .success(let userAccount):
            if let info = userAccount.info, info.isExpired {
                completion(.failure(.expired))
            } else {
                completion(.success(userAccount))
            }
        }
    }
}
