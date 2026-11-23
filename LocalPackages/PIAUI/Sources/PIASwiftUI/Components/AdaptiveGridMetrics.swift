//
//  AdaptiveGridMetrics.swift
//  PIASwiftUI
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

/// Columns for a grid whose items share the width evenly and never get narrower than a minimum
///
/// Unlike `GridItem(.adaptive(minimum:))` it exposes the resulting item width and column count, so
/// items can size themselves from it, for example to stay square when there's more than one column.
///
/// ```swift
/// let metrics = AdaptiveGridMetrics(width: proxy.size.width, minimumItemWidth: 150, spacing: 16)
/// LazyVGrid(columns: metrics.columns) {
///     ForEach(items) { CardView(item: $0, width: metrics.itemWidth) }
/// }
/// ```
public struct AdaptiveGridMetrics: Equatable, Sendable {
    /// How many items fit side by side, always at least one
    public let columnCount: Int
    /// The width of every item; below the minimum only when a single column doesn't fit it
    public let itemWidth: CGFloat
    /// The space between columns
    public let spacing: CGFloat

    /// - Parameters:
    ///   - width: The width the grid lays out in, without any padding around it.
    ///   - minimumItemWidth: The narrowest an item may be before a column is dropped.
    ///   - spacing: The space between columns.
    public init(width: CGFloat, minimumItemWidth: CGFloat, spacing: CGFloat) {
        let width = max(0, width)
        let spacing = max(0, spacing)
        let minimumItemWidth = max(1, minimumItemWidth)

        let columnCount = max(1, Int((width + spacing) / (minimumItemWidth + spacing)))
        self.columnCount = columnCount
        self.itemWidth = (width - spacing * CGFloat(columnCount - 1)) / CGFloat(columnCount)
        self.spacing = spacing
    }

    /// Fixed-width columns for a `LazyVGrid`
    public var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(itemWidth), spacing: spacing), count: columnCount)
    }
}
