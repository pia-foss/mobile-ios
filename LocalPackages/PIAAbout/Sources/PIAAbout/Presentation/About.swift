//
//  About.swift
//  PIAAbout
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

public enum About {}

extension About {
    public struct State: Equatable {
        public var header: String
        public var components: AboutComponents?
        public var licenseTexts: [String: String] = [:]
        public var unavailableLicenses: Set<String> = []

        public init(header: String) {
            self.header = header
        }
    }

    enum Action: Equatable {
        case onAppear
        case componentsLoaded(AboutComponents)
        case licenseLoaded(name: String, text: String?)
    }

    public struct Dependencies: Sendable {
        public var loadComponents: @MainActor () -> AboutComponents
        public var fetchLicense: @MainActor (URL) async -> String?

        public init(
            loadComponents: @escaping @MainActor () -> AboutComponents,
            fetchLicense: @escaping @MainActor (URL) async -> String?
        ) {
            self.loadComponents = loadComponents
            self.fetchLicense = fetchLicense
        }
    }
}
