//
//  DebugReportDependencySpy.swift
//  PIADebugReportTests
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

@testable import PIADebugReport

final class DebugReportDependencySpy: @unchecked Sendable {
    private(set) var buildCallCount = 0

    var buildResult = DebugReport(sections: [
        DebugReport.Section(id: "application.log", name: "application.log", content: "log", kind: .debugLog),
        DebugReport.Section(
            id: "device_information",
            name: "device_information",
            content: "iPhone",
            kind: .mandatory
        )
    ])

    private(set) var submitCallCount = 0
    private(set) var submittedReport: DebugReport?
    var submitResult: Result<String, any Error> = .success("ABC123")

    private(set) var emittedOutputs: [DebugReportReview.Output] = []

    func makeDependencies() -> DebugReportReview.Dependencies {
        .init(
            buildReport: { [self] in
                buildCallCount += 1
                return buildResult
            },
            submitReport: { [self] report in
                submitCallCount += 1
                submittedReport = report
                return try submitResult.get()
            },
            emit: { [self] output in emittedOutputs.append(output) }
        )
    }
}

struct DebugReportReviewTestError: Error {}
