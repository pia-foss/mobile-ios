//
//  SignupUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 5/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS
import PIALibrary

class SignupUseCaseMock: SignupUseCaseType {
    private let result: Result<PIA_VPN_tvOS.UserAccount, Error>
    
    init(result: Result<PIA_VPN_tvOS.UserAccount, Error>) {
        self.result = result
    }
    
    func callAsFunction(email: String, transaction: PIALibrary.InAppTransaction?) async throws -> PIA_VPN_tvOS.UserAccount {
        switch result {
            case .success(let userAccount):
                return userAccount
            case .failure(let error):
                throw error
        }
    }
}
