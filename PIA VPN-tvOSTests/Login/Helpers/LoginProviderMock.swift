//
//  LoginProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 4/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class LoginProviderMock: LoginProviderType {
    private let result: Result<UserAccount, Error>
    
    init(result: Result<UserAccount, Error>) {
        self.result = result
    }
    
    func login(with credentials: Credentials, completion: @escaping (Result<UserAccount, Error>) -> Void) {
        completion(result)
    }
}
