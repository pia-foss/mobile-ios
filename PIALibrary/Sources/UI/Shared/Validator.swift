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
 
    /**
     Validates an email address.
     
     - Parameter email: The email address to validate.
     - Returns: `true` if the address syntax is valid.
     */
    public static func validate(email: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "^[^\\s]+@((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,}$").evaluate(with: email)
    }

    /**
     Validates a gift code.
     
     - Parameter giftCode: The gift code to validate.
     - Returns: `true` if the code syntax is valid.
     */
    public static func validate(giftCode: String, withDashes: Bool = false) -> Bool {
        if withDashes {
            return NSPredicate(format: "SELF MATCHES %@", "^(\\d{4}-){3}\\d{4}$").evaluate(with: giftCode)
        } else {
            return NSPredicate(format: "SELF MATCHES %@", "^\\d{16}$").evaluate(with: giftCode)
        }
    }
}
