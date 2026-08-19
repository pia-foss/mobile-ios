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

    func login(with credentials: Credentials, completion: @escaping (Result<UserAccount, Error>) -> Void) {
        let request = LoginRequest(credentials: credentials)

        accountProvider.login(with: request) { [weak self] result in
            self?.handleLoginResult(result: result, completion: completion)
        }
    }

    func login(with receipt: JWS, completion: @escaping (Result<UserAccount, Error>) -> Void) {
        let request = LoginReceiptRequest(receipt: receipt)

        accountProvider.login(with: request) { [weak self] result in
            self?.handleLoginResult(result: result, completion: completion)
        }
    }

    private func handleLoginResult(
        result: ClientResult<UserAccount>,
        completion: @escaping (Result<UserAccount, Error>) -> Void
    ) {
        if case let .failure(error) = result {
            completion(.failure(error))
            return
        }

        guard case let .success(userAccount) = result else {
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
