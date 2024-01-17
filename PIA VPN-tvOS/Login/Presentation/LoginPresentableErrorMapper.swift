//
//  LoginPresentableErrorMapper.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 28/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

class LoginPresentableErrorMapper {
    func map(error: LoginError) -> String? {
        switch error {
            case .unauthorized:
                return L10n.Welcome.Login.Error.unauthorized
            case .throttled(retryAfter: let retryAfter):
                return L10n.Welcome.Login.Error.throttled(retryAfter)
            case .generic(message: let message):
                return message
            case .usernameWrongFormat, .passwordWrongFormat:
                return L10n.Welcome.Login.Error.validation
            default:
                return nil
        }
    }
}
