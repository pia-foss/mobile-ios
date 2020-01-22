//
//  DebugLog.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/14/17.
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

/// Packs up metadata about the target of a `DebugLog`.
public struct LogTarget {

    /// The app version.
    public var appVersion: String

    /// The operating system version.
    public var osVersion: String

    /// The device type.
    public var deviceType: String
    
    /// :nodoc:
    public init(appVersion: String, osVersion: String, deviceType: String) {
        self.appVersion = appVersion
        self.osVersion = osVersion
        self.deviceType = deviceType
    }
}

/// Generic implementation of a debug log.
public protocol DebugLog {

    /// The debug log ID.
    var identifier: String { get }
    
    /// The content of the log.
    var content: String { get }
    
    /// Returns `true` if the log has no content.
    var isEmpty: Bool { get }
    
    /// The optional `LogTarget` of this log.
    var target: LogTarget? { get }
    
    /**
     Returns a serialized `Data` representation of this log.

     - Returns: A `Data` representation of this log.
     */
    func serialized() -> Data
}
