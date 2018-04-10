//
//  UserAccount.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/23/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// The compound user account.
public struct UserAccount: CustomStringConvertible {

    /// The account credentials.
    public let credentials: Credentials
    
    /// The associated account informations.
    public let info: AccountInfo?

    /// Shortcut for `info.isRenewable`.
    ///
    /// - Seealso: `AccountInfo.isRenewable`
    public var isRenewable: Bool {
        return info?.isRenewable ?? false
    }

    /// :nodoc:
    public init(credentials: Credentials, info: AccountInfo?) {
        self.credentials = credentials
        self.info = info
    }

    // MARK: CustomStringConvertible
    
    /// :nodoc:
    public var description: String {
        if let info = self.info {
            return "{username: \(credentials.username), info: \(info)}"
        } else {
            return "{username: \(credentials.username)}"
        }
    }
}
