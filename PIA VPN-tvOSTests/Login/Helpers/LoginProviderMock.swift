//
//  LoginProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 4/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIABase

@testable import PIA_VPN_tvOS

final class LoginProviderMock: LoginProviderType {
    private let result: ClientResult<UserAccount>

    init(result: ClientResult<UserAccount>) {
        self.result = result
    }

    func login(with credentials: Credentials, completion: @escaping ClientCallback<UserAccount>) {
        completion(result)
    }

    func login(with receipt: JWS, completion: @escaping ClientCallback<UserAccount>) {
        completion(result)
    }
}
