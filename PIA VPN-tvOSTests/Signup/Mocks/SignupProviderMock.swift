//
//  SignupProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 28/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
@testable import PIA_VPN_tvOS

class SignupProviderMock: SignupProviderType {
    private let result: Result<UserAccount, SignupError>
    
    init(result: Result<UserAccount, SignupError>) {
        self.result = result
    }
    
    func signup(email: String, transaction: InAppTransaction?, _ callback: @escaping (Result<UserAccount, SignupError>) -> Void) {
        callback(result)
    }
}
