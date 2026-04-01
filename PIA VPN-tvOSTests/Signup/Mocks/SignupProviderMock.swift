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
    private let result: Result<PIA_VPN_tvOS.UserAccount, SignupError>
    
    init(result: Result<PIA_VPN_tvOS.UserAccount, SignupError>) {
        self.result = result
    }
    
    func signup(email: String, transaction: PIALibrary.InAppTransaction?, _ callback: @escaping (Result<PIA_VPN_tvOS.UserAccount, SignupError>) -> Void) {
        callback(result)
    }
}
