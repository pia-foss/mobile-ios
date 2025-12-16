//
//  TypographySnapshotTests.swift
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

@Suite("Typography Snapshots")
@MainActor
struct TypographySnapshotTests {

    @MainActor
    @Test func typographyPreview() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    // MARK: - Accessibility Tests

    @MainActor
    @Test("Typography with Extra Small accessibility size")
    func typographyAccessibilityExtraSmall() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .extraSmall)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test("Typography with Small accessibility size")
    func typographyAccessibilitySmall() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .small)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test("Typography with Medium (default) accessibility size")
    func typographyAccessibilityMedium() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .medium)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test("Typography with Large accessibility size")
    func typographyAccessibilityLarge() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .large)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test("Typography with Extra Large accessibility size")
    func typographyAccessibilityExtraLarge() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .extraLarge)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test("Typography with Extra Extra Large accessibility size")
    func typographyAccessibilityExtraExtraLarge() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .extraExtraLarge)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test("Typography with Extra Extra Extra Large accessibility size")
    func typographyAccessibilityExtraExtraExtraLarge() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test("Typography with Accessibility Medium accessibility size")
    func typographyAccessibilityMediumSize() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .accessibilityMedium)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test("Typography with Accessibility Large accessibility size")
    func typographyAccessibilityLargeSize() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .accessibilityLarge)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test("Typography with Accessibility Extra Large accessibility size")
    func typographyAccessibilityExtraLargeSize() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .accessibilityExtraLarge)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test("Typography with Accessibility Extra Extra Large accessibility size")
    func typographyAccessibilityExtraExtraLargeSize() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }

    @MainActor
    @Test("Typography with Accessibility Extra Extra Extra Large accessibility size")
    func typographyAccessibilityExtraExtraExtraLargeSize() {
        guard !SnapshotTestHelpers.isRunningOnXcodeCloud else { return }

        let view = TypographyPreview()
            .environment(\.colorScheme, .light)
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
            .frame(width: 1024)
            .fixedSize()

        assertSnapshot(
            of: view,
            as: .image(traits: .init(displayScale: 1.0))
        )
    }
}
