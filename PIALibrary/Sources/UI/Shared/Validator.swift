//
//  Validator.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/21/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
    public static func validate(giftCode: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "^\\d{16}$").evaluate(with: giftCode)
    }
}
