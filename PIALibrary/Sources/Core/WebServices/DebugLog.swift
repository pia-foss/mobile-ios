//
//  DebugLog.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/14/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
