//
//  WelcomeBackOutput.swift
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

extension WelcomeBack {

    /// Everything the welcome-back screen asks its host to do. The screen knows nothing about
    /// navigation — it only reports what happened.
    public enum Output {
        /// The receipt signed the customer in.
        case didAuthenticate(user: UserAccount)

        /// The customer wants to sign in with a username and password instead.
        case requestLogin

        /// Nothing could be restored.
        case didDismiss
    }
}
