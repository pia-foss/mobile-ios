//
//  DebugReportReview+Reducer.swift
//  PIADebugReport
//
//  Copyright © 2026 Private Internet Access, Inc.
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
import Foundation
import PIALibrary

extension DebugReportReview {

    public struct Reducer: Sendable {
        let dependencies: Dependencies

        public init(dependencies: Dependencies) {
            self.dependencies = dependencies
        }

        public func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .onAppear:
                guard !state.hasBuilt else { return nil }
                return build(&state)

            case .reportBuilt(let report):
                state.sections = report.sections
                state.isBuilding = false
                state.hasBuilt = true
                return nil

            case .sendTapped:
                guard state.canSend else { return nil }
                state.isSending = true
                let report = DebugReport(sections: state.sections)
                return .task { [dependencies] in
                    do {
                        return .submitted(.success(try await dependencies.submitReport(report)))
                    } catch {
                        return .submitted(.failure(.submission))
                    }
                }

            case .submitted(.success(let reportId)):
                state.isSending = false
                state.hasSubmitted = true
                return emit(.didSubmit(reportId: reportId))

            case .submitted(.failure):
                state.isSending = false
                return emit(.submissionFailed)
            }
        }

        /// Builds the report. The shared effect id means a repeated appearance while a build is in
        /// flight cancels it rather than racing it.
        private func build(_ state: inout State) -> Effect<Action>? {
            state.isBuilding = true
            return .task(id: Self.buildEffectId) { [dependencies] in
                .reportBuilt(await dependencies.buildReport())
            }
        }

        private func emit(_ output: Output) -> Effect<Action> {
            .fireAndForget { [dependencies] in dependencies.emit(output) }
        }

        private static let buildEffectId = "buildDebugReport"
    }
}
