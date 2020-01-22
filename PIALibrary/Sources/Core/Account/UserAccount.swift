//
//  UserAccount.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/23/17.
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
