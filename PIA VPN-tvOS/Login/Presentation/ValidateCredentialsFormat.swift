//
//  ValidateCredentialsFormat.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 26/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary



protocol ValidateCredentialsFormatType {
    func callAsFunction(username: String, password: String) -> Result<Void, LoginError>
}

class ValidateCredentialsFormat: ValidateCredentialsFormatType {
    func callAsFunction(username: String, password: String) -> Result<Void, LoginError> {
        let usernameText = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordText = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !usernameText.isEmpty else { return .failure(.usernameWrongFormat) }
        guard !passwordText.isEmpty else { return .failure(.passwordWrongFormat) }
        
        return .success(())
    }
}
