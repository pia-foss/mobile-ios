//
//  DebugReportReview+Live.swift
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

// The host builds the report and submission closures from `Client`, so nothing here reaches for
// the global service locator (see ADR 0009).
extension DebugReportReview.Dependencies {

    public static func live(
        buildReport: @escaping @Sendable () async -> DebugReport,
        submitReport: @escaping @Sendable (DebugReport) async throws -> String,
        emit: @MainActor @escaping (DebugReportReview.Output) -> Void
    ) -> Self {
        .init(buildReport: buildReport, submitReport: submitReport, emit: emit)
    }
}
