//
//  LoginQRCode.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 5/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

public struct LoginQRCode {
    let token: String
    var url: URL? {
        URL(string: "PIA://token=\(token)")
    }
    let expiresAt: Date
}
