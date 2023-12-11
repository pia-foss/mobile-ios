//
//  LoginProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 4/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
@testable import PIA_VPN_tvOS

class LoginProviderMock: LoginProviderType {
    private let userResult: UserAccount?
    private let errorResult: Error?
    
    init(userResult: UserAccount?, errorResult: Error?) {
        self.userResult = userResult
        self.errorResult = errorResult
    }
    
    func login(with request: LoginRequest, _ callback: LibraryCallback<UserAccount>?) {
        callback?(userResult, errorResult)
    }
}
