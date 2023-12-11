//
//  LoginError.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 29/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

enum LoginError: Error {
    case unauthorized
    case throttled(retryAfter: Double)
    case expired
    case usernameWrongFormat
    case passwordWrongFormat
    case generic(message: String?)
}
