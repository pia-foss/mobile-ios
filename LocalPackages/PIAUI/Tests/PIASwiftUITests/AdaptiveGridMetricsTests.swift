//
//  AdaptiveGridMetricsTests.swift
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

import CoreGraphics
import Testing

@testable import PIASwiftUI

@Suite
struct AdaptiveGridMetricsTests {
    @Test func fitsAsManyColumnsAsTheMinimumWidthAllows() {
        // 2 × 150 + 16 = 316 fits, 3 × 150 + 2 × 16 = 482 does not
        let metrics = AdaptiveGridMetrics(width: 350, minimumItemWidth: 150, spacing: 16)

        #expect(metrics.columnCount == 2)
        #expect(metrics.itemWidth == 167)
    }

    @Test func itemsShareTheWidthExactly() {
        let metrics = AdaptiveGridMetrics(width: 1000, minimumItemWidth: 150, spacing: 16)

        let usedWidth = metrics.itemWidth * CGFloat(metrics.columnCount) + 16 * CGFloat(metrics.columnCount - 1)
        #expect(metrics.columnCount == 6)
        #expect(abs(usedWidth - 1000) < 0.001)
        #expect(metrics.itemWidth >= 150)
    }

    @Test func keepsOneColumnWhenTheMinimumDoesNotFit() {
        let metrics = AdaptiveGridMetrics(width: 120, minimumItemWidth: 150, spacing: 16)

        #expect(metrics.columnCount == 1)
        #expect(metrics.itemWidth == 120)
    }

    @Test func handlesAZeroOrNegativeWidth() {
        let metrics = AdaptiveGridMetrics(width: -10, minimumItemWidth: 0, spacing: 0)

        #expect(metrics.columnCount == 1)
        #expect(metrics.itemWidth == 0)
    }

    @Test func columnsMatchTheMetrics() {
        let metrics = AdaptiveGridMetrics(width: 350, minimumItemWidth: 150, spacing: 16)

        #expect(metrics.columns.count == 2)
        #expect(metrics.columns.allSatisfy { $0.spacing == 16 })
    }
}
