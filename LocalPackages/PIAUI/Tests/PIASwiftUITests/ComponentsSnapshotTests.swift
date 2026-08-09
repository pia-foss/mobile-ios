//
//  ComponentsSnapshotTests.swift
//  PIASwiftUITests
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

import SnapshotTesting
import SwiftUI
import Testing

@testable import PIASwiftUI

@Suite("PIASwiftUI Component Snapshots")
@MainActor
struct ComponentsSnapshotTests {

    /// `true` on Xcode Cloud, where reference images are not checked out.
    private static var isRunningOnXcodeCloud: Bool {
        ProcessInfo.processInfo.environment["CI_XCODE_PROJECT"] != nil
            || ProcessInfo.processInfo.environment["CI_XCODEBUILD_ACTION"] != nil
    }

    private static let precision: Float = 0.99

    @Test func componentsLight() {
        guard !Self.isRunningOnXcodeCloud else { return }

        let view = ComponentsPreview()
            .environment(\.colorScheme, .light)
            .frame(width: 375)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(precision: Self.precision, traits: .init(displayScale: 1.0))
        )
    }

    @Test func componentsDark() {
        guard !Self.isRunningOnXcodeCloud else { return }

        let view = ComponentsPreview()
            .environment(\.colorScheme, .dark)
            .frame(width: 375)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(precision: Self.precision, traits: .init(displayScale: 1.0))
        )
    }

    @Test("Components at the largest accessibility text size")
    func componentsAccessibilityExtraExtraExtraLarge() {
        guard !Self.isRunningOnXcodeCloud else { return }

        let view = ComponentsPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
            .frame(width: 375)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(precision: Self.precision, traits: .init(displayScale: 1.0))
        )
    }
}
