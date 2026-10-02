//
//  ValidateQRLogin.swift
//  PIAValidateQRLogin
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

public enum ValidateQRLogin {}

extension ValidateQRLogin {

    public enum Phase: Equatable, Sendable {
        case idle
        case confirming
        case validating
        case failed
        case finished
    }

    public struct State: Equatable {
        public var phase: Phase

        public init(phase: Phase = .idle) {
            self.phase = phase
        }
    }

    public enum Action {
        case onAppear
        case confirmTapped
        case cancelTapped
        case validated(Result<Void, any Error>)
        case errorAcknowledged
    }

    /// Everything the screen asks its host to do.
    public enum Output: Equatable, Sendable {
        case dismiss
    }

    public struct Dependencies: Sendable {
        public var validate: @Sendable () async -> Result<Void, any Error>
        public var discardQRToken: @Sendable () -> Void
        public var emit: @MainActor (Output) -> Void

        public init(
            validate: @Sendable @escaping () async -> Result<Void, any Error>,
            discardQRToken: @Sendable @escaping () -> Void,
            emit: @MainActor @escaping (Output) -> Void
        ) {
            self.validate = validate
            self.discardQRToken = discardQRToken
            self.emit = emit
        }
    }
}
