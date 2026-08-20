//
//  LoginProviderType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 27/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIABase
import PIALibrary

protocol LoginProviderType {
    func login(with credentials: Credentials, completion: @escaping ClientCallback<UserAccount>)
    func login(with receipt: JWS, completion: @escaping ClientCallback<UserAccount>)
}
