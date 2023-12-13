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
                return "Your username or password is incorrect."
            case .throttled(retryAfter: let retryAfter):
                return "Too many failed login attempts with this username. Please try again after \(retryAfter) second(s)."
            case .generic(message: let message):
                return message
            case .usernameWrongFormat, .passwordWrongFormat:
                return "You must enter a username and password."
            default:
                return nil
        }
    }
}
