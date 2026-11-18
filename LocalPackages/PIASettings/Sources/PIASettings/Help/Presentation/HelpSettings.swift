//
//  HelpSettings.swift
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

public enum HelpSettings {}

extension HelpSettings {
    public struct Preferences: Equatable, Sendable {
        public var debugLogging: Bool
        public var sharesServiceQualityData: Bool

        public init(debugLogging: Bool, sharesServiceQualityData: Bool) {
            self.debugLogging = debugLogging
            self.sharesServiceQualityData = sharesServiceQualityData
        }
    }

    public struct State: Equatable, Sendable {
        public var preferences: Preferences
        public let version: String
        public let isDebugLoggingEditable: Bool

        public init(preferences: Preferences, version: String, isDebugLoggingEditable: Bool) {
            self.preferences = preferences
            self.version = version
            self.isDebugLoggingEditable = isDebugLoggingEditable
        }
    }

    public enum Action: Equatable, Sendable {
        case sendDebugReportTapped
        case debugLoggingToggled(Bool)
        case shareServiceQualityDataToggled(Bool)
        case serviceQualityInformationTapped
        case serviceQualityEventsTapped
        case latestNewsTapped
    }

    public struct Dependencies: Sendable {
        public let setDebugLogging: @MainActor @Sendable (Bool) -> Void
        public let setSharesServiceQualityData: @MainActor @Sendable (Bool) -> Void
        public let showDebugReport: @MainActor @Sendable () -> Void
        public let showServiceQualityInformation: @MainActor @Sendable () -> Void
        public let showServiceQualityEvents: @MainActor @Sendable () -> Void
        public let showLatestNews: @MainActor @Sendable () -> Void

        public init(
            setDebugLogging: @MainActor @Sendable @escaping (Bool) -> Void,
            setSharesServiceQualityData: @MainActor @Sendable @escaping (Bool) -> Void,
            showDebugReport: @MainActor @Sendable @escaping () -> Void,
            showServiceQualityInformation: @MainActor @Sendable @escaping () -> Void,
            showServiceQualityEvents: @MainActor @Sendable @escaping () -> Void,
            showLatestNews: @MainActor @Sendable @escaping () -> Void,
        ) {
            self.setDebugLogging = setDebugLogging
            self.setSharesServiceQualityData = setSharesServiceQualityData
            self.showDebugReport = showDebugReport
            self.showServiceQualityInformation = showServiceQualityInformation
            self.showServiceQualityEvents = showServiceQualityEvents
            self.showLatestNews = showLatestNews
        }
    }
}
