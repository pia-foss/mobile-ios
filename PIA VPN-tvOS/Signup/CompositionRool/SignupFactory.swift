//
//  SignupFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 23/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class SignUpFactory {
    static func makeSignupView() -> SignupView {
        let url = URL(string: "https://www.privateinternetaccess.com/buy-vpn-online")!
        return SignupView(signUpURL: url)
    }
}
