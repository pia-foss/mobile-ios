//
//  CustomDNSSettings.swift
//  PIASettings
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

public enum CustomDNSSettings {}

extension CustomDNSSettings {
    public enum Alert: Equatable, Sendable {
        case primaryMandatory
        case primaryInvalid
        case secondaryInvalid
        case clearConfirmation
    }

    public struct State: Equatable, Sendable {
        public var primary: String
        public var secondary: String
        public var isClearable: Bool
        public var alert: Alert?

        public init(servers: [String]) {
            primary = servers.first ?? ""
            secondary = servers.count > 1 ? servers.last ?? "" : ""
            isClearable = !servers.isEmpty
        }

        var isAlertPresented: Bool { alert != nil }

        var servers: [String] {
            secondary.isEmpty ? [primary] : [primary, secondary]
        }

        var validationError: Alert? {
            if primary.isEmpty { return .primaryMandatory }
            if !CustomDNSSettings.isValidIPv4(primary) { return .primaryInvalid }
            if !secondary.isEmpty, !CustomDNSSettings.isValidIPv4(secondary) { return .secondaryInvalid }
            return nil
        }
    }

    public enum Action: Equatable, Sendable {
        case primaryChanged(String)
        case secondaryChanged(String)
        case updateTapped
        case clearTapped
        case clearConfirmed
        case alertDismissed
    }

    public struct Dependencies: Sendable {
        public let save: @MainActor @Sendable ([String]) -> Void
        public let clear: @MainActor @Sendable () -> Void
        public let dismiss: @MainActor @Sendable () -> Void

        public init(
            save: @MainActor @Sendable @escaping ([String]) -> Void,
            clear: @MainActor @Sendable @escaping () -> Void,
            dismiss: @MainActor @Sendable @escaping () -> Void,
        ) {
            self.save = save
            self.clear = clear
            self.dismiss = dismiss
        }
    }

    private static let ipv4Pattern =
        "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"

    static func isValidIPv4(_ address: String) -> Bool {
        address.range(of: ipv4Pattern, options: .regularExpression) != nil
    }
}
