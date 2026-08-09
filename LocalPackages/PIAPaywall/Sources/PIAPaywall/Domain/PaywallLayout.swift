//
//  PaywallLayout.swift
//  PIAPaywall
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
import SwiftUI

/// Which of the two designed arrangements the paywall renders.
public enum PaywallLayout: Equatable, Sendable {
    /// Single centred column. iPhone in both orientations, and iPad in portrait.
    case compact

    /// Benefits in a row, hero beside the trial card, a close button in the corner.
    /// iPad in landscape.
    case wide
}

public extension PaywallLayout {
    /// Resolves the layout from the canvas the paywall actually has.
    ///
    /// Deliberately **not** a pure size-class decision: iPad portrait and iPad landscape are both
    /// `(.regular, .regular)`, yet the design arranges them differently. The width/height comparison
    /// is what separates them, and the `horizontalSizeClass` check keeps a landscape iPhone — which
    /// is wider than it is tall but is `.compact` — on the single-column layout.
    ///
    /// The 900pt floor keeps narrow iPad multitasking splits on the compact layout, where the
    /// three-across benefits row would not fit.
    static func resolve(size: CGSize, horizontalSizeClass: UserInterfaceSizeClass?) -> PaywallLayout {
        guard horizontalSizeClass == .regular else { return .compact }
        guard size.width > size.height, size.width >= 900 else { return .compact }
        return .wide
    }
}
