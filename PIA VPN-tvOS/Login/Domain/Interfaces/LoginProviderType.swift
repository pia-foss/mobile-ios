//
//  LoginProviderType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 27/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol LoginProviderType {
    func login(with request: LoginRequest, _ callback: LibraryCallback<UserAccount>?)
}
