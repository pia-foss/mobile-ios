//
//  ColorSnapshotTests.swift
//  PIADesignSystem
//
//  Created by snapshot testing on 08.12.25.
//  Copyright © 2025 Private Internet Access, Inc.
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

import Testing
import SwiftUI
import SnapshotTesting
@testable import PIADesignSystem

@Suite("Color Snapshots")
@MainActor
struct ColorSnapshotTests {

    @MainActor
    @Test func colorPreviewLight() {
        let view = ColorPreview()
            .environment(\.colorScheme, .light)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test func colorPreviewDark() {
        let view = ColorPreview()
            .environment(\.colorScheme, .dark)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

}
