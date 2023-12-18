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

extension LoginError: Equatable {
    public static func == (lhs: LoginError, rhs: LoginError) -> Bool {
        switch (lhs, rhs) {
            case (.unauthorized, .unauthorized), (.expired, .expired), (.usernameWrongFormat, .usernameWrongFormat), (.passwordWrongFormat, .passwordWrongFormat):
                return true
            case let (.throttled(lhsDelay), .throttled(rhsDelay)):
                return lhsDelay == rhsDelay
            case let (.generic(lhsMessage), .generic(rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
        }
    }
}
