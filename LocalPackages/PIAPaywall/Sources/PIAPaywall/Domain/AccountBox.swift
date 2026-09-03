//
//  AccountBox.swift
//  PIAPaywall
//
//  Copyright © 2026 Private Internet Access, Inc.
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

import PIALibrary

/// A `UserAccount`, boxed so it can ride on an `Equatable` action. Compared by username.
public struct AccountBox: Equatable {
    public let value: UserAccount

    public init(_ value: UserAccount) {
        self.value = value
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value.credentials.username == rhs.value.credentials.username
    }
}
