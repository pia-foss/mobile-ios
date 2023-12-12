//
//  Equatable.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 29/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS
import PIALibrary

extension LoginStatus: Equatable {
    public static func == (lhs: LoginStatus, rhs: LoginStatus) -> Bool {
        switch (lhs, rhs) {
            case (.none, .none), (.isLogging, .isLogging):
                return true
            case let (.failed(lhsError), .failed(rhsError)):
                return lhsError == rhsError
            case let (.succeeded(lhsAccount), .succeeded(rhsAccount)):
                return lhsAccount == rhsAccount
            default:
                return false
        }
    }
}

extension LoginError: Equatable {
    public static func == (lhs: LoginError, rhs: LoginError) -> Bool {
        switch (lhs, rhs) {
            case (.unauthorized, .unauthorized), (.expired, .expired), (.usernameWrongFormat, .usernameWrongFormat), (.passwordWrongFormat, .passwordWrongFormat):
                return true
            case let (.throttled(lhsDelay), .throttled(rhsDelay)):
                return lhsDelay == rhsDelay
            default:
                return false
        }
    }
}
