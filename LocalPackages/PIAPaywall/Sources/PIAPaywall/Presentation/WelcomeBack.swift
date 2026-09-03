//
//  WelcomeBack.swift
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

public enum WelcomeBack {}

extension WelcomeBack {

    public struct State: Equatable {
        public var isRestoring: Bool

        public init(isRestoring: Bool = false) {
            self.isRestoring = isRestoring
        }
    }

    enum Action: Equatable {
        case appStoreAccountTapped
        case restoreSucceeded(AccountBox)
        case restoreFailed
        case usernameAndPasswordTapped
    }

    public struct Dependencies {
        /// Signs in with the receipt this App Store account already holds. Does not synchronise
        /// entitlements with Apple first.
        public var restore: @MainActor () async -> Result<UserAccount, PaywallError>

        public var emit: @MainActor (Output) -> Void

        public init(
            restore: @escaping @MainActor () async -> Result<UserAccount, PaywallError>,
            emit: @escaping @MainActor (Output) -> Void
        ) {
            self.restore = restore
            self.emit = emit
        }
    }
}
