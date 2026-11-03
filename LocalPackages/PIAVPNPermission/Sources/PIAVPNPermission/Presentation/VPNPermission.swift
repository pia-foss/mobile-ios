//
//  VPNPermission.swift
//  PIAVPNPermission
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

public enum VPNPermission {}

extension VPNPermission {

    public enum Phase: Equatable, Sendable {
        case idle
        /// The system "Add VPN Configurations" prompt is up.
        case requesting
        /// The person declined, or installing the profile failed.
        case denied
        case finished
    }

    public struct State: Equatable {
        public var phase: Phase
        /// Whether the denied dialog offers to email customer support.
        public var canContactSupport: Bool

        public init(phase: Phase = .idle, canContactSupport: Bool = false) {
            self.phase = phase
            self.canContactSupport = canContactSupport
        }
    }

    public enum Action {
        case onAppear
        case mailAvailabilityLoaded(canSendMail: Bool)
        case submitTapped
        case permissionResult(Result<Void, any Error>)
        case contactSupportTapped
        case deniedAcknowledged
    }

    /// Everything the screen asks its host to do.
    public enum Output: Equatable, Sendable {
        /// The profile is installed; the screen can close.
        case granted
        /// Open the support email composer. The screen stays on screen behind it.
        case contactSupport
    }

    public struct Dependencies: Sendable {
        public var requestPermission: @MainActor () async -> Result<Void, any Error>
        public var canSendMail: @MainActor () -> Bool
        public var emit: @MainActor (Output) -> Void

        public init(
            requestPermission: @MainActor @escaping () async -> Result<Void, any Error>,
            canSendMail: @MainActor @escaping () -> Bool,
            emit: @MainActor @escaping (Output) -> Void
        ) {
            self.requestPermission = requestPermission
            self.canSendMail = canSendMail
            self.emit = emit
        }
    }
}
