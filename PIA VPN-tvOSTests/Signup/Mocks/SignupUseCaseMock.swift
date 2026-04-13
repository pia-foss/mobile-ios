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

class SignupUseCaseMock: PIA_VPN_tvOS.SignupUseCaseType {
    private let result: Result<UserAccount, Error>
    
    init(result: Result<UserAccount, Error>) {
        self.result = result
    }
    
    func callAsFunction(email: String, transaction: InAppTransaction?) async throws -> UserAccount {
        switch result {
            case .success(let userAccount):
                return userAccount
            case .failure(let error):
                throw error
        }
    }
}
