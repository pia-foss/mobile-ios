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
        let url = URL(string: "https://apps.apple.com/us/app/vpn-by-private-internet-access/id955626407")!
        return SignupView(signUpURL: url)
    }
}
