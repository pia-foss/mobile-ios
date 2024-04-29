//
//  SignupProviderType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 27/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol SignupProviderType {
    func signup(email: String, transaction: InAppTransaction?, _ callback: @escaping (Result<UserAccount, Error>) -> Void)
}
