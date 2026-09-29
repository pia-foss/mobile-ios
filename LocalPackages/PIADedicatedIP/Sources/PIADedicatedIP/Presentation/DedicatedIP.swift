//
//  DedicatedIP.swift
//  PIADedicatedIP
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

public enum DedicatedIP {}

extension DedicatedIP {

    /// The activated Dedicated IP, reduced to what the screen shows.
    public struct Info: Equatable, Sendable {
        public let name: String
        public let country: String
        public let ip: String?

        public init(name: String, country: String, ip: String?) {
            self.name = name
            self.country = country
            self.ip = ip
        }
    }

    public struct State: Equatable {
        public var isLoading = false
        public var token = ""
        public var dip: Info?
        var retryUntil: Date?
    }

    public enum Failure: Error, Equatable, Sendable {
        case alreadyHasOne
        case expired
        case invalid
        case unauthorized
        case throttled(retryAfter: TimeInterval)
    }

    public enum Action: Equatable {
        case tokenChanged(String)
        case activateTapped
        case activated(Result<Info, Failure>)
        case removeConfirmed
        case removed(Info?)
    }

    /// A banner the host should display.
    public struct Note: Equatable, Sendable {
        public enum Kind: Equatable, Sendable {
            case success
            case sticky
            case timed(TimeInterval)
        }

        public let kind: Kind
        public let message: String

        public init(kind: Kind, message: String) {
            self.kind = kind
            self.message = message
        }
    }

    /// Everything the screen asks its host to do.
    public enum Output: Equatable, Sendable {
        case showNote(Note)
        /// The Dedicated IP changed, so the host should restyle and refresh.
        case didChange
        /// The session is no longer valid, so the host should log out.
        case unauthorized
    }

    public struct Dependencies: Sendable {
        public var getDedicatedIP: @Sendable () -> Info?
        public var activate: @Sendable (String) async -> Result<Info, Failure>
        public var remove: @Sendable () async -> Void
        public var emit: @MainActor (Output) -> Void

        public init(
            getDedicatedIP: @Sendable @escaping () -> Info?,
            activate: @Sendable @escaping (String) async -> Result<Info, Failure>,
            remove: @Sendable @escaping () async -> Void,
            emit: @MainActor @escaping (Output) -> Void
        ) {
            self.getDedicatedIP = getDedicatedIP
            self.activate = activate
            self.remove = remove
            self.emit = emit
        }
    }
}
