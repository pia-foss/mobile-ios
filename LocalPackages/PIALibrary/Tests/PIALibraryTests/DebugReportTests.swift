//
//  DebugReportTests.swift
//  PIALibraryTests
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
import Testing

@testable import PIALibrary

@Suite("DebugReport Tests")
struct DebugReportTests {

    private func section(
        _ name: String,
        _ content: String,
        _ kind: DebugReport.SectionKind = .mandatory
    ) -> DebugReport.Section {
        DebugReport.Section(id: name, name: name, content: content, kind: kind)
    }

    @Test("Sections are joined in the CSI report format")
    func textMatchesCSIFormat() {
        let report = DebugReport(sections: [
            section("application.log", "line one"),
            section("device_information", "iPhone14,2"),
        ])

        #expect(
            report.text
                == "/PIA_PART/application.log\nline one\n\n/PIA_PART/device_information\niPhone14,2\n\n"
        )
    }

    @Test("An empty report produces empty text")
    func emptyReportHasEmptyText() {
        #expect(DebugReport(sections: []).text.isEmpty)
    }

    @Test("sections(of:) keeps only the requested kind, preserving order")
    func filteringByKind() {
        let report = DebugReport(sections: [
            section("protocol_information", "a"),
            section("application.log", "b", .debugLog),
            section("tunnel.log", "c", .tunnelLog),
        ])

        #expect(report.sections(of: .mandatory).map(\.name) == ["protocol_information"])
        #expect(report.sections(of: .debugLog).map(\.name) == ["application.log"])
        #expect(report.sections(of: .tunnelLog).map(\.name) == ["tunnel.log"])
    }
}

@Suite("DebugReportBuilder Tests")
struct DebugReportBuilderTests {

    @Test("A component with content becomes a section tagged with its kind")
    func contentBecomesSection() {
        let report = DebugReportBuilder.assemble([
            .init(sectionName: "application.log", content: "line", kind: .debugLog),
            .init(sectionName: "device_information", content: "iPhone14,2", kind: .mandatory),
        ])

        #expect(report.sections.map(\.name) == ["application.log", "device_information"])
        #expect(report.sections.map(\.kind) == [.debugLog, .mandatory])
        #expect(report.sections.first?.id == "application.log")
        #expect(report.sections.first?.content == "line")
    }

    @Test(
        "Components without content are dropped, empty content is kept",
        arguments: [
            (nil as String?, ["a", "c"]),
            ("" as String?, ["a", "b", "c"]),
        ]
    )
    func nilContentIsDropped(content: String?, expectedNames: [String]) {
        let report = DebugReportBuilder.assemble([
            .init(sectionName: "a", content: "kept", kind: .mandatory),
            .init(sectionName: "b", content: content, kind: .debugLog),
            .init(sectionName: "c", content: "", kind: .tunnelLog),
        ])

        #expect(report.sections.map(\.name) == expectedNames)
    }
}
