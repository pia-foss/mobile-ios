//
//  DebugReportReview.swift
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

import Foundation
import PIALibrary

/// A screen that shows everything a debug report about to be sent to CSI contains before the user
/// submits it.
public enum DebugReportReview {}

extension DebugReportReview {

    /// What the screen shows. The report is all or nothing: every section shown is sent.
    public struct State: Equatable {
        public var sections: [DebugReport.Section]
        public var isBuilding: Bool
        public var isSending: Bool
        public var hasBuilt: Bool
        /// Set once the report was accepted by CSI, so the same report is never sent twice.
        public var hasSubmitted: Bool

        public init() {
            self.sections = []
            self.isBuilding = false
            self.isSending = false
            self.hasBuilt = false
            self.hasSubmitted = false
        }

        /// Whether the report is ready, nothing is already being submitted, and it wasn't sent yet.
        public var canSend: Bool {
            hasBuilt && !isBuilding && !isSending && !hasSubmitted
        }

        /// The exact text that would be submitted, for preview and "save".
        public var reportText: String {
            DebugReport(sections: sections).text
        }
    }

    public enum Action {
        case onAppear
        case reportBuilt(DebugReport)
        case sendTapped
        case submitted(Result<String, Failure>)
    }

    public enum Failure: Error, Equatable, Sendable {
        case submission
    }

    /// Everything the screen asks its host to do.
    public enum Output: Equatable, Sendable {
        case didSubmit(reportId: String)
        case submissionFailed
    }

    public struct Dependencies: Sendable {
        /// Builds the full report, without sending it.
        public var buildReport: @Sendable () async -> DebugReport
        /// Submits a report that was previously built and reviewed.
        public var submitReport: @Sendable (DebugReport) async throws -> String
        public var emit: @MainActor (Output) -> Void

        public init(
            buildReport: @Sendable @escaping () async -> DebugReport,
            submitReport: @Sendable @escaping (DebugReport) async throws -> String,
            emit: @MainActor @escaping (Output) -> Void
        ) {
            self.buildReport = buildReport
            self.submitReport = submitReport
            self.emit = emit
        }
    }
}
