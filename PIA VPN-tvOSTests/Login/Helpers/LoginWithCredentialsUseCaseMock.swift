//
//  LoginWithCredentialsUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 29/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS
import PIALibrary

class LoginWithCredentialsUseCaseMock: LoginWithCredentialsUseCaseType {
    private let result: Result<UserAccount, LoginError>
    
    init(result: Result<UserAccount, LoginError>) {
        self.result = result
    }
    
    func execute(username: String, password: String, completion: @escaping (Result<UserAccount, LoginError>) -> Void) {
        completion(result)
    }
}
