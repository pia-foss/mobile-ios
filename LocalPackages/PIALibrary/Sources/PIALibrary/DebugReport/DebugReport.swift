//
//  DebugReport.swift
//  PIALibrary
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
import PIACSI

/// The set of sections that make up a debug report submitted to CSI.
///
/// Produced by `DebugReportBuilder` so the report can be reviewed before it is submitted: what a
/// review screen shows is the exact `text` that gets sent.
public struct DebugReport: Sendable, Equatable {

    /// How a section participates in the report.
    ///
    /// Lets a review screen present the categories the user can include or exclude, mirroring the
    /// desktop support tool's "Include technical debug logs" / "Include crash reports" toggles.
    public enum SectionKind: Sendable, Equatable {
        /// Always included; the user cannot exclude these.
        case mandatory
        /// The application log, included only when debug logging is enabled.
        case debugLog
        /// The tunnel log from the Network Extension (live, or the copy it persisted last).
        case tunnelLog
    }

    /// A single CSI section, before it is joined into the report text.
    public struct Section: Sendable, Equatable, Identifiable {
        /// The CSI section name, e.g. `application.log`. Unique within a report.
        public let id: String
        public let name: String
        public let content: String
        public let kind: SectionKind

        public init(id: String, name: String, content: String, kind: SectionKind) {
            self.id = id
            self.name = name
            self.content = content
            self.kind = kind
        }
    }

    public let sections: [Section]

    public init(sections: [Section]) {
        self.sections = sections
    }

    /// The exact text submitted to CSI, in the same format as `CSIReportBuilder`.
    public var text: String {
        CSIReportBuilder.build(
            sections: sections.map { CSIReportSection(name: $0.name, content: $0.content) }
        )
    }

    /// The sections belonging to `kind`, preserving their order in the report.
    public func sections(of kind: SectionKind) -> [Section] {
        sections.filter { $0.kind == kind }
    }
}
