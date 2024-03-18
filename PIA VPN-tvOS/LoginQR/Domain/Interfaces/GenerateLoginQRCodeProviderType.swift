//
//  GenerateLoginQRCodeProviderType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 10/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol GenerateLoginQRCodeProviderType {
    func generateLoginQRCodeToken() async throws -> LoginQRCode
}
