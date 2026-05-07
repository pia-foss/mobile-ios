//
//  Platform.swift
//  PIALibrary
//
//  Created by Mario on 06/05/2026.
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

public struct Platform {
    /// True when the platform is either "Designed for iPad" or Catalyst.
    public static var isRunningOnMac: Bool { isiOSAppOnMac || isMacCatalystApp }

    /// True when an iOS binary is running on Apple Silicon Mac as "Designed for iPad".
    /// Always false on real iPhone/iPad, on the iOS Simulator, and on tvOS.
    public static var isiOSAppOnMac: Bool = {
        #if os(iOS)
            return ProcessInfo.processInfo.isiOSAppOnMac
        #else
            return false
        #endif
    }()

    /// True when the platform is Max Catalyst
    public static var isMacCatalystApp: Bool = {
        #if targetEnvironment(macCatalyst)
            return ProcessInfo.processInfo.isMacCatalystApp
        #else
            return false
        #endif
    }()
}
