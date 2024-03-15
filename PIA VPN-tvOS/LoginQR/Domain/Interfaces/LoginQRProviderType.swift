//
//  LoginQRProviderType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 12/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol LoginQRProviderType {
    func login(with linkToken: String, _ callback: ((PIALibrary.UserAccount?, Error?) -> Void)?)
}
