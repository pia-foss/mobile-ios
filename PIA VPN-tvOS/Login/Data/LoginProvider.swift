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
    private var accountProvider: AccountProvider
    
    init(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider
    }
    
    func login(with request: LoginRequest, _ callback: LibraryCallback<UserAccount>?) {
        accountProvider.login(with: request, callback)
    }
}
