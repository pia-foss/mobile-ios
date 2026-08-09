//
//  PaywallLayoutTests.swift
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

import SwiftUI
import XCTest

@testable import PIAPaywall

/// Layout selection is a pure function of the canvas, so the whole reflow matrix is covered here
/// without rendering anything.
final class PaywallLayoutTests: XCTestCase {

    func test_iPhonePortrait_THEN_compact() {
        // GIVEN an iPhone 17 Pro in portrait
        let layout = PaywallLayout.resolve(size: CGSize(width: 402, height: 874), horizontalSizeClass: .compact)

        // THEN the single column layout
        XCTAssertEqual(layout, .compact)
    }

    /// Wider than it is tall, but still a phone. A pure width > height test would wrongly reflow it.
    func test_iPhoneLandscape_THEN_compact() {
        // GIVEN an iPhone in landscape
        let layout = PaywallLayout.resolve(size: CGSize(width: 874, height: 402), horizontalSizeClass: .compact)

        // THEN still the single column layout
        XCTAssertEqual(layout, .compact)
    }

    /// Both iPad orientations are `(.regular, .regular)`, so size class alone cannot separate them.
    func test_iPadPortrait_THEN_compact() {
        // GIVEN an 11" iPad in portrait
        let layout = PaywallLayout.resolve(size: CGSize(width: 834, height: 1194), horizontalSizeClass: .regular)

        // THEN the design keeps the single column
        XCTAssertEqual(layout, .compact)
    }

    func test_iPadLandscape_THEN_wide() {
        // GIVEN an 11" iPad in landscape
        let layout = PaywallLayout.resolve(size: CGSize(width: 1194, height: 834), horizontalSizeClass: .regular)

        // THEN the reflowed layout
        XCTAssertEqual(layout, .wide)
    }

    func test_iPadLargeLandscape_THEN_wide() {
        // GIVEN a 13" iPad in landscape
        let layout = PaywallLayout.resolve(size: CGSize(width: 1366, height: 1024), horizontalSizeClass: .regular)

        // THEN the reflowed layout
        XCTAssertEqual(layout, .wide)
    }

    func test_iPadHalfSplitView_THEN_compact() {
        // GIVEN a landscape iPad sharing the screen 1/2
        let layout = PaywallLayout.resolve(size: CGSize(width: 570, height: 834), horizontalSizeClass: .compact)

        // THEN too narrow for the three-across benefits row
        XCTAssertEqual(layout, .compact)
    }

    func test_iPadThirdSplitView_THEN_compact() {
        // GIVEN a landscape iPad sharing the screen 1/3
        let layout = PaywallLayout.resolve(size: CGSize(width: 375, height: 834), horizontalSizeClass: .compact)

        // THEN the single column layout
        XCTAssertEqual(layout, .compact)
    }

    /// A regular-width canvas that is landscape-shaped but still narrow, e.g. a resized Catalyst
    /// window. The 900pt floor keeps it on the layout that fits.
    func test_regularButNarrowLandscape_THEN_compact() {
        // GIVEN an 880pt wide landscape canvas
        let layout = PaywallLayout.resolve(size: CGSize(width: 880, height: 700), horizontalSizeClass: .regular)

        // THEN below the floor, so single column
        XCTAssertEqual(layout, .compact)
    }
}
