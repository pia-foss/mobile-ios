//
//  LoginDomainErrorMapper.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 4/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class LoginDomainErrorMapper: LoginDomainErrorMapperType {
    func map(error: Error?) -> LoginError {
        guard let clientError = error as? ClientError else {
            return .generic(message: error?.localizedDescription)
        }
        
        switch clientError {
        case .unauthorized:
            return .unauthorized

        case .throttled(retryAfter: let retryAfter):
            return .throttled(retryAfter: Double(retryAfter))
            
        case .expired:
            return .expired
        default:
            return .generic(message: error?.localizedDescription)
        }
    }
}
