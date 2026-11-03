//
//  ForceUpdate+Live.swift
//  PIAForceUpdate
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

import Foundation

extension ForceUpdate.Dependencies {

    static let appStoreURL = URL(string: "https://itunes.apple.com/app/private-internet-access-anonymous/id955626407")!

    /// - Parameters:
    ///   - uninstallVPNProfiles: Runs before the App Store opens, so the update never replaces the
    ///     app while its tunnel is up.
    public static func live(
        isVPNConnected: @Sendable @escaping () -> Bool,
        uninstallVPNProfiles: @MainActor @escaping () -> Void,
        openURL: @MainActor @escaping (URL) -> Void
    ) -> ForceUpdate.Dependencies {
        ForceUpdate.Dependencies(
            isVPNConnected: isVPNConnected,
            update: {
                uninstallVPNProfiles()
                openURL(appStoreURL)
            }
        )
    }
}
