//
//  SignupPaywallSnapshotTests.swift
//  PIAPaywallTests
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
import XCTest

@testable import PIAPaywall

/// A dense, token-heavy screen with a reflow and a light/dark spec: exactly the case where a visual
/// regression is invisible to unit tests and expensive in revenue.
///
/// Every case is driven from a fixed `PaywallState` with dependencies that never resolve, so nothing
/// here depends on StoreKit, the network or timing.
@MainActor
final class SignupPaywallSnapshotTests: XCTestCase {

    /// Reference images are not checked out on Xcode Cloud.
    private var isRunningOnXcodeCloud: Bool {
        ProcessInfo.processInfo.environment["CI_XCODE_PROJECT"] != nil
            || ProcessInfo.processInfo.environment["CI_XCODEBUILD_ACTION"] != nil
    }

    private static let precision: Float = 0.99
    private static let phone = CGSize(width: 402, height: 874)
    private static let landscapeTablet = CGSize(width: 1194, height: 834)

    private func assert(
        _ state: PaywallState,
        size: CGSize = SignupPaywallSnapshotTests.phone,
        colorScheme: ColorScheme = .light,
        sizeCategory: ContentSizeCategory = .large,
        // `#filePath`, not `#file`: this target compiles in Swift 6 language mode, where
        // `ConciseMagicFile` shortens `#file` to "PIAPaywallTests/…". swift-snapshot-testing derives
        // the `__Snapshots__` directory from it, so with `#file` the references are written into the
        // simulator's data container instead of the source tree — where they would be re-recorded on
        // every clean run and never actually assert anything.
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        guard !isRunningOnXcodeCloud else { return }

        let view = PaywallPreviewFixtures.view(state)
            .environment(\.colorScheme, colorScheme)
            .environment(\.sizeCategory, sizeCategory)
            .frame(width: size.width, height: size.height)

        assertSnapshot(
            of: view,
            as: .image(
                precision: Self.precision,
                layout: .fixed(width: size.width, height: size.height),
                // `displayScale: 1.0` matches the rest of the repo's snapshot tests. Left at the
                // simulator's native 3x these references are nine times the pixels — 16MB for this
                // suite — for no extra regression-catching value at 0.99 precision, and every copy
                // change would add another copy of that to the repository's history.
                // `UITraitCollection` has no combined initialiser, so the two are composed.
                traits: UITraitCollection(traitsFrom: [
                    UITraitCollection(displayScale: 1.0),
                    UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
                ])
            ),
            file: file,
            testName: testName,
            line: line
        )
    }

    // MARK: - Compact

    func test_trialLight() {
        assert(PaywallPreviewFixtures.state())
    }

    func test_trialDark() {
        assert(PaywallPreviewFixtures.state(), colorScheme: .dark)
    }

    /// The timeline card must disappear rather than describe a trial that will not happen.
    func test_withoutTrial() {
        assert(PaywallPreviewFixtures.state(isEligibleForIntroOffer: false))
    }

    /// Prices are redacted, not guessed, and the call to action is disabled.
    func test_loadingProducts() {
        assert(PaywallPreviewFixtures.state(phase: .loadingProducts))
    }

    /// The failure is inline with a retry, and Restore stays available.
    func test_productsUnavailable() {
        assert(PaywallPreviewFixtures.state(phase: .productsUnavailable))
    }

    // MARK: - Wide

    func test_wideLight() {
        assert(
            PaywallPreviewFixtures.state(layout: .wide, isDismissable: true),
            size: Self.landscapeTablet
        )
    }

    func test_wideDark() {
        assert(
            PaywallPreviewFixtures.state(layout: .wide, isDismissable: true),
            size: Self.landscapeTablet,
            colorScheme: .dark
        )
    }

    // MARK: - Choose your plan sheet

    func test_sheetYearlySelected() {
        assert(PaywallPreviewFixtures.state(isPlanSheetPresented: true, sheetSelection: .yearly))
    }

    /// Selecting monthly swaps both the disclaimer and the call to action, even though the account
    /// is trial-eligible: the trial is only ever sold on the yearly plan.
    func test_sheetMonthlySelected() {
        assert(PaywallPreviewFixtures.state(isPlanSheetPresented: true, sheetSelection: .monthly))
    }

    func test_sheetDark() {
        assert(
            PaywallPreviewFixtures.state(isPlanSheetPresented: true, sheetSelection: .yearly),
            colorScheme: .dark
        )
    }

    /// On a landscape iPad the sheet is a centred card rather than a bottom sheet.
    func test_sheetWide() {
        assert(
            PaywallPreviewFixtures.state(layout: .wide, isPlanSheetPresented: true),
            size: Self.landscapeTablet
        )
    }

    /// Without a trial the badge must drop the "7-day Free Trial" promise.
    func test_sheetWithoutTrial() {
        assert(
            PaywallPreviewFixtures.state(isEligibleForIntroOffer: false, isPlanSheetPresented: true)
        )
    }

    // MARK: - Accessibility

    /// The timeline connector has to stretch to whatever height the step text needs; this is where
    /// a hardcoded height would show up.
    func test_largestAccessibilityTextSize() {
        assert(
            PaywallPreviewFixtures.state(),
            sizeCategory: .accessibilityExtraExtraExtraLarge
        )
    }
}
