//
//  AttributedStringHighlightingTests.swift
//  PIAUI
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

import SwiftUI
import Testing

@testable import PIASwiftUI

struct AttributedStringHighlightingTests {

    @Test("Only the highlighted substring is restyled")
    func restylesSubstring() throws {
        let sut = AttributedString("Manage it here.", highlighting: "here.") { $0.foregroundColor = .red }

        let styled = sut.runs.filter { $0.foregroundColor == .red }.map { String(sut[$0.range].characters) }
        #expect(styled == ["here."])
    }

    @Test("A missing substring leaves the string plain")
    func missingSubstring() {
        let sut = AttributedString("Manage it here.", highlighting: "there") { $0.foregroundColor = .red }

        #expect(sut == AttributedString("Manage it here."))
    }
}
