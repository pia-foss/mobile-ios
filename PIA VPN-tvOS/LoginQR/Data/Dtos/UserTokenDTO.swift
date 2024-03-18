//
//  UserTokenDTO.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 10/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

struct UserTokenDTO: Decodable {
    let token: String
    let expiresAt: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case token = "api_token"
        case expiresAt = "expires_at"
        case userId = "kape_user_id"
    }
}
