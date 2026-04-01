//
//  Notification+UI.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 12/30/17.
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

// TODO: make this (mostly) work for both iOS and macOS
// e.g. use Macros always, which in turn may return UIColor/NSColor

public extension Notification.Name {
    
    // MARK: UI
    
    /// Posted following a theme switch.
    static let PIAThemeDidChange = Notification.Name("PIAThemeDidChange")
    
    /// Reload the tiles.
    static let PIATilesDidChange = Notification.Name("PIATilesDidChange")
    
    /// Reload the tiles with animation.
    static let PIAUpdateFixedTiles = Notification.Name("PIAUpdateFixedTiles")

    /// Present Recover Signup page
    static let PIARecoverAccount = Notification.Name("PIARecoverAccount")

    /// User toggled the dark mode
    static let PIAThemeShouldChange = Notification.Name("PIAThemeShouldChange")

    /// User clicked the magic link and got a valid token
    static let PIAFinishLoginWithMagicLink = Notification.Name("PIALoginWithMagicLink")
    
    /// User is unathorized
    static let PIAUnauthorized = Notification.Name("Unauthorized")

}
