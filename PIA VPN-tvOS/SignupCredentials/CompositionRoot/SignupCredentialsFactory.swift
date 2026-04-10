//
//  SignupCredentialsFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 14/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class SignupCredentialsFactory {
    static var userAccount: UserAccount?
    
    static func makeSignupCredentialsView() -> SignupCredentialsView {
        guard let credentials = userAccount?.credentials else {
            fatalError("Can't be created without user credentials")
        }
        
        return SignupCredentialsView(credentials: credentials, action: {
            NotificationCenter.default.post(name: .PIAAccountDidLogin, object: nil)
        })
    }
}
