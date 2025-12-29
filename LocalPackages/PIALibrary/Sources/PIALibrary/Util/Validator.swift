//
//  Validator.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/21/17.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

/**
 Provides useful validation methods.
 */
public class Validator {
    public enum EmailValidationError: Error {
        case emailIsEmpty
        case emailIsInvalid
    }

    /**
     Validates an email address.
     
     - Parameter email: The email address to validate.
     - Throws: A `EmailValidationError` if validation fails.
     */
    public static func validate(email: String?) throws(EmailValidationError) {
        guard let email, !email.isEmpty else {
            throw EmailValidationError.emailIsEmpty
        }

        // Check for consecutive dots
        guard !email.contains("..") else {
            throw EmailValidationError.emailIsInvalid
        }

        // Check for multiple @ symbols
        guard email.filter({ $0 == "@" }).count == 1 else {
            throw EmailValidationError.emailIsInvalid
        }

        // Email regex explanation:
        // Local part: ^[A-Za-z0-9]([A-Za-z0-9._+-]*[A-Za-z0-9])?
        //   - Must start with alphanumeric
        //   - Can contain letters, numbers, dots, underscores, plus, hyphen in the middle
        //   - Must end with alphanumeric (or be single character)
        //   - This prevents leading/trailing dots
        // Domain part: @((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,}$
        //   - Standard domain validation
        let emailRegex = "^[A-Za-z0-9]([A-Za-z0-9._+-]*[A-Za-z0-9])?@((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,}$"

        guard NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email) else {
            throw EmailValidationError.emailIsInvalid
        }
    }
}
