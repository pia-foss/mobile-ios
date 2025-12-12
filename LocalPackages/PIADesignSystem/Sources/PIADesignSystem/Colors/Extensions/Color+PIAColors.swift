//
//  Color+PIAColors.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 08.12.25.
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

import SwiftUI

/// Represents a gradient with a start and end color.
public struct PIAGradient: Sendable {
    /// The starting color of the gradient.
    public let start: Color
    /// The ending color of the gradient.
    public let end: Color
}

/// PIA Design System color extensions.
///
/// Provides semantic colors from the PIA design system with automatic light/dark mode support.
/// Colors are loaded from the PIADesignSystem package's asset catalog.
///
/// Example:
/// ```swift
/// Text("Connect")
///     .foregroundColor(.pia.primary)
///
/// Button("Subscribe") { }
///     .background(Color.pia.primary)
///     .foregroundColor(.pia.onPrimary)
///
/// Text("Get Started")
///     .typography(.title1, color: .pia.primary)
/// ```
public extension Color {
    /// PIA Design System colors namespace
    enum PIA {
        /// Light: #037900 / Dark: #5DDF5A
        public static let primary = Color(.Primary.primary)

        /// Light: #FFFFFF / Dark: #323642
        public static let onPrimary = Color(.Primary.onPrimary)

        /// Light: #B0024C / Dark: #FF72A5
        public static let error = Color(.Error.error)

        /// #FFFFFF
        public static let onError = Color(.Error.onError)

        /// Light: #EEEEEE / Dark: #323642
        public static let background = Color(.Background.background)

        /// Light: #323642 / Dark: #EEEEEE
        public static let onBackground = Color(.Background.onBackground)

        /// Light: #EEEEEE / Dark: #323642
        public static let surface = Color(.Surface.surface)

        /// #1B1D22 at 40% opacity
        public static let surfaceOverlay = Color(.Surface.surfaceOverlay)

        /// Light: #FFFFFF / Dark: #454557
        public static let surfaceContainerPrimary = Color(.Surface.surfaceContainerPrimary)

        /// Light: #D7D8D9 / Dark: #5C6370
        public static let surfaceContainerSecondary = Color(.Surface.surfaceContainerSecondary)

        /// Light: #323642 / Dark: #EEEEEE
        public static let onSurface = Color(.Surface.onSurface)

        /// Light: #5C6370 / Dark: #D7D8D9
        public static let onSurfaceContainerPrimary = Color(.Surface.onSurfaceContainerPrimary)

        /// Light: #889099 / Dark: #A8ADB3
        public static let onSurfaceContainerSecondary = Color(.Surface.onSurfaceContainerSecondary)

        /// Light: #D7D8D9 / Dark: #889099
        public static let outline = Color(.Outline.outline)

        /// Light: #889099 / Dark: #D7D8D9
        public static let outlineVariantPrimary = Color(.Outline.outlineVariantPrimary)

        /// Light: #323642 / Dark: #EEEEEE
        public static let inverseSurface = Color(.Inverse.inverseSurface)

        /// Light: #EEEEEE / Dark: #323642
        public static let inverseOnSurface = Color(.Inverse.inverseOnSurface)

        /// #FEF1F5
        public static let errorContainer = Color(.Fixed.errorContainer)

        /// #FEE4D3
        public static let warningContainer = Color(.Fixed.warningContainer)

        /// #EDF5FE
        public static let infoContainer = Color(.Fixed.infoContainer)

        /// #D9F6D5
        public static let successContainer = Color(.Fixed.successContainer)

        /// #FF72A5
        public static let onErrorOutline = Color(.Fixed.onErrorOutline)

        /// #FEA754
        public static let onWarningOutline = Color(.Fixed.onWarningOutline)

        /// #86D0FD
        public static let onInfoOutline = Color(.Fixed.onInfoOutline)

        /// #88E47B
        public static let onSuccessOutline = Color(.Fixed.onSuccessOutline)

        /// #B0024C
        public static let onErrorContainer = Color(.Fixed.onErrorContainer)

        /// #943511
        public static let onWarningContainer = Color(.Fixed.onWarningContainer)

        /// #0171C4
        public static let onInfoContainer = Color(.Fixed.onInfoContainer)

        /// #037900
        public static let onSuccessContainer = Color(.Fixed.onSuccessContainer)

        /// Start: #4CB649 / End: #5DD5FA
        public static let surfaceStatusConnected = PIAGradient(
            start: Color(.Fixed.Gradient.SurfaceStatusConnected.start),
            end: Color(.Fixed.Gradient.SurfaceStatusConnected.end)
        )

        /// Start: #E6B400 / End: #F9CF01
        public static let surfaceStatusConnecting = PIAGradient(
            start: Color(.Fixed.Gradient.SurfaceStatusConnecting.start),
            end: Color(.Fixed.Gradient.SurfaceStatusConnecting.end)
        )

        /// Start: #B2352D / End: #F24458
        public static let surfaceStatusError = PIAGradient(
            start: Color(.Fixed.Gradient.SurfaceStatusError.start),
            end: Color(.Fixed.Gradient.SurfaceStatusError.end)
        )
    }

    /// Convenience accessor for PIA colors
    static var pia: PIA.Type { PIA.self }
}
