//
//  LoginQRCodeDomainMapper.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 12/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class LoginQRCodeDomainMapper {
    func map(dto: LoginQRTokenDTO) -> LoginQRCode? {
        guard let date = Date.makeISO8601Date(string: dto.expiresAt) else { return nil }
        return LoginQRCode(token: dto.token, expiresAt: date)
    }
    
    func map(dto: UserTokenDTO) -> UserToken? {
        guard let date = Date.makeISO8601Date(string: dto.expiresAt) else { return nil }
        return UserToken(token: dto.token, expiresAt: date, userId: dto.userId)
    }
}
