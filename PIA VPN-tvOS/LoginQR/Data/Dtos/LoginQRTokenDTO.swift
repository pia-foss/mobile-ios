//
//  LoginQRTokenDTO.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 10/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

struct LoginQRTokenDTO: Decodable {
    let token: String
    let expiresAt: String
    
    enum CodingKeys: String, CodingKey {
        case token = "login_token"
        case expiresAt = "expires_at"
    }
}
