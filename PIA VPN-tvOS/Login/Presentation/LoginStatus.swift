//
//  LoginStatus.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 13/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

enum LoginCredentialsError {
    case none
    case username
    case password
}

enum LoginStatus {
    case none
    case isLogging
    case failed(errorMessage: String?, field: LoginCredentialsError)
    case succeeded(userAccount: UserAccount)
}

extension LoginStatus: Equatable {
    public static func == (lhs: LoginStatus, rhs: LoginStatus) -> Bool {
        switch (lhs, rhs) {
            case (.none, .none), (.isLogging, .isLogging):
                return true
            case let (.failed(lhsErrorMessage, lhsField), .failed(rhsErrorMessage, rhsField)):
                return lhsErrorMessage == rhsErrorMessage && lhsField == rhsField
            case let (.succeeded(lhsAccount), .succeeded(rhsAccount)):
                return lhsAccount == rhsAccount
            default:
                return false
        }
    }
}
