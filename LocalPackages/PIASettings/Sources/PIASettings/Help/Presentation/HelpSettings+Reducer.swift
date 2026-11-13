//
//  HelpSettings+Reducer.swift
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

import CoreArchitecture

extension HelpSettings {
    struct Reducer: Sendable {
        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .sendDebugReportTapped:
                guard !state.isSubmittingDebugReport else { return nil }
                state.isSubmittingDebugReport = true
                return .task { [dependencies] in
                    do {
                        let id = try await dependencies.submitDebugReport()
                        return .debugReportSubmitted(id.isEmpty ? .empty : .submitted(id: id))
                    } catch {
                        return .debugReportSubmitted(.failed)
                    }
                }

            case .debugReportSubmitted(let report):
                state.isSubmittingDebugReport = false
                state.debugReport = report
                return nil

            case .debugReportDismissed:
                state.debugReport = nil
                return nil

            case .copyDebugReportIDTapped(let id):
                state.debugReport = nil
                return .fireAndForget { [dependencies] in dependencies.copyToPasteboard(id) }

            case .debugLoggingToggled(let isOn):
                guard state.isDebugLoggingEditable, state.preferences.debugLogging != isOn else { return nil }
                state.preferences.debugLogging = isOn
                return .fireAndForget { [dependencies] in
                    dependencies.setDebugLogging(isOn)
                    if !isOn {
                        dependencies.clearLogs()
                    }
                }

            case .shareServiceQualityDataToggled(let isOn):
                guard state.preferences.sharesServiceQualityData != isOn else { return nil }
                state.preferences.sharesServiceQualityData = isOn
                return .fireAndForget { [dependencies] in dependencies.setSharesServiceQualityData(isOn) }

            case .serviceQualityInformationTapped:
                return .fireAndForget { [dependencies] in dependencies.showServiceQualityInformation() }

            case .serviceQualityEventsTapped:
                return .fireAndForget { [dependencies] in dependencies.showServiceQualityEvents() }

            case .latestNewsTapped:
                return .fireAndForget { [dependencies] in dependencies.showLatestNews() }
            }
        }
    }
}
