//
//  PIALogHandler.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 18.12.25.
//  Copyright © 2025 Private Internet Access, Inc.
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

import Logging
import Foundation

public struct PIALogHandler: LogHandler {

    public static let logStorage = PIALogStorage()
    private static let dateFormatter = ISO8601DateFormatter()
    public var logLevel: Logger.Level = .debug
    public var metadata: Logger.Metadata = [:]
    private let label: String

    public init(label: String) {
        self.label = label
    }

    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        if level <= .debug, !Client.preferences.debugLogging {
            return
        }

        let timestamp = Self.dateFormatter.string(from: Date())
        let levelString = "[\(level.rawValue.uppercased())]"
        let logMessage = "\(timestamp) \(levelString) \(label): \(message)"

        PIALogHandler.logStorage.append(logMessage)
    }
}

public final class PIALogStorage {
    private var logs: [String] = []
    private let queue = DispatchQueue(label: "PIALogStorage", attributes: .concurrent)
    private let maxLogEntries = 1000

    func append(_ message: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            logs.append(message)

            if logs.count > maxLogEntries {
                let logsToRemove = logs.count - maxLogEntries
                logs.removeFirst(logsToRemove)
            }
        }
    }

    public func getAllLogs() -> String {
        queue.sync {
            return logs.joined(separator: "\n")
        }
    }

    public func clear() {
        queue.async(flags: .barrier) { [weak self] in
            self?.logs.removeAll()
        }
    }
}
