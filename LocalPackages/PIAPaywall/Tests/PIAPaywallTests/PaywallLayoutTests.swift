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
import Testing

@testable import PIAPaywall

/// Layout selection is a pure function of the canvas, so the whole reflow matrix is covered here
/// without rendering anything.
struct PaywallLayoutTests {

    /// One canvas the layout must resolve, named for the device that produces it.
    ///
    /// The matrix is data rather than a test each, so a new device is a new row.
    struct Canvas: Sendable, CustomTestStringConvertible {
        let device: String
        let size: CGSize
        let horizontalSizeClass: UserInterfaceSizeClass
        let expected: PaywallLayout

        /// Why this row is in the matrix, when that is not obvious from the numbers.
        let because: String

        var testDescription: String { "\(device) → \(expected)" }
    }

    @Test("Canvas reflow matrix", arguments: PaywallLayoutTests.canvases)
    func resolvesLayout(for canvas: Canvas) {
        let layout = PaywallLayout.resolve(
            size: canvas.size,
            horizontalSizeClass: canvas.horizontalSizeClass
        )

        #expect(layout == canvas.expected, "\(canvas.device): \(canvas.because)")
    }

    static let canvases: [Canvas] = [
        Canvas(
            device: "iPhone 17 Pro portrait",
            size: CGSize(width: 402, height: 874),
            horizontalSizeClass: .compact,
            expected: .compact,
            because: "the single column layout"
        ),
        Canvas(
            device: "iPhone landscape",
            size: CGSize(width: 874, height: 402),
            horizontalSizeClass: .compact,
            expected: .compact,
            because: "wider than it is tall, but still a phone — a pure width > height test would wrongly reflow it"
        ),
        Canvas(
            device: "11-inch iPad portrait",
            size: CGSize(width: 834, height: 1194),
            horizontalSizeClass: .regular,
            expected: .compact,
            because: "both iPad orientations are (.regular, .regular), so size class alone cannot separate them"
        ),
        Canvas(
            device: "11-inch iPad landscape",
            size: CGSize(width: 1194, height: 834),
            horizontalSizeClass: .regular,
            expected: .wide,
            because: "the reflowed layout"
        ),
        Canvas(
            device: "13-inch iPad landscape",
            size: CGSize(width: 1366, height: 1024),
            horizontalSizeClass: .regular,
            expected: .wide,
            because: "the reflowed layout"
        ),
        Canvas(
            device: "11-inch iPad, 1/2 split",
            size: CGSize(width: 570, height: 834),
            horizontalSizeClass: .compact,
            expected: .compact,
            because: "narrow enough that the system reports .compact, so the size class already rules out wide"
        ),
        Canvas(
            device: "13-inch iPad, 1/2 split",
            size: CGSize(width: 678, height: 1024),
            horizontalSizeClass: .regular,
            expected: .compact,
            because: "stays .regular, so only the measured canvas keeps it off wide — a size-class check would get this wrong"
        ),
        Canvas(
            device: "13-inch iPad, 2/3 split",
            size: CGSize(width: 904, height: 1024),
            horizontalSizeClass: .regular,
            expected: .compact,
            because: "past the 900pt floor, but portrait-shaped, so still the single column"
        ),
        Canvas(
            device: "iPad, 1/3 split",
            size: CGSize(width: 375, height: 834),
            horizontalSizeClass: .compact,
            expected: .compact,
            because: "the single column layout"
        ),
        Canvas(
            device: "resized Catalyst window",
            size: CGSize(width: 880, height: 700),
            horizontalSizeClass: .regular,
            expected: .compact,
            because: "regular and landscape-shaped but below the 900pt floor, so the layout that fits"
        )
    ]
}
