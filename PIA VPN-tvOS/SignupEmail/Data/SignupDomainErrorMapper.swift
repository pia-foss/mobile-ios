//
//  SignupDomainErrorMapper.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 09/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class SignupDomainErrorMapper {
    func map(error: Error?) -> SignupError {
        guard let clientError = error as? ClientError, clientError == .noReceipt else {
            return .generic
        }
        return .noReceipt
    }
}
