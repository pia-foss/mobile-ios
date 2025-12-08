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
@available(iOS 13.0, *)
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
@available(iOS 13.0, *)
public extension Color {
    /// PIA Design System colors namespace
    enum PIA {
        /// Primary brand color for main UI elements, buttons, and accents
        /// - Light mode: #037900
        /// - Dark mode: #5DDF5A
        public static let primary = Color(.Primary.primary)

        /// Color to use on top of primary color (for text, icons, etc.)
        /// - Light mode: #FFFFFF
        /// - Dark mode: #323642
        public static let onPrimary = Color(.Primary.onPrimary)

        /// Error color for error states, alerts, and destructive actions
        /// - Light mode: #B0024C
        /// - Dark mode: #FF72A5
        public static let error = Color(.Error.error)

        /// Color to use on top of error color (for text, icons, etc.)
        /// - Light mode: #FFFFFF
        /// - Dark mode: #FFFFFF
        public static let onError = Color(.Error.onError)

        /// Background color for main views and surfaces
        /// - Light mode: #EEEEEE
        /// - Dark mode: #323642
        public static let background = Color(.Background.background)

        /// Color to use on top of background color (for text, icons, etc.)
        /// - Light mode: #323642
        /// - Dark mode: #EEEEEE
        public static let onBackground = Color(.Background.onBackground)

        /// Surface color for elements like cards, sheets, and menus
        /// - Light mode: #EEEEEE
        /// - Dark mode: #323642
        public static let surface = Color(.Surface.surface)

        /// Surface overlay color for elements like modals and dialogs
        /// - Light/Dark mode: #1B1D22 at 40% opacity
        public static let surfaceOverlay = Color(.Surface.surfaceOverlay)

        /// Primary surface container color
        /// - Light mode: #FFFFFF
        /// - Dark mode: #454557
        public static let surfaceContainerPrimary = Color(.Surface.surfaceContainerPrimary)

        /// Secondary surface container color
        /// - Light mode: #D7D8D9
        /// - Dark mode: #5C6370
        public static let surfaceContainerSecondary = Color(.Surface.surfaceContainerSecondary)

        /// Color for text and icons on top of surface colors
        /// - Light mode: #323642
        /// - Dark mode: #EEEEEE
        public static let onSurface = Color(.Surface.onSurface)

        /// Color for text and icons on top of primary surface container colors
        /// - Light mode: #5C6370
        /// - Dark mode: #D7D8D9
        public static let onSurfaceContainerPrimary = Color(.Surface.onSurfaceContainerPrimary)

        /// Color for text and icons on top of secondary surface container colors
        /// - Light mode: #889099
        /// - Dark mode: #A8ADB3
        public static let onSurfaceContainerSecondary = Color(.Surface.onSurfaceContainerSecondary)

        /// Outline color for borders and dividers
        /// - Light mode: #D7D8D9
        /// - Dark mode: #889099
        public static let outline = Color(.Outline.outline)

        /// Primary variant outline color
        /// - Light mode: #889099
        /// - Dark mode: #D7D8D9
        public static let outlineVariantPrimary = Color(.Outline.outlineVariantPrimary)

        /// Inverse surface color for elements that need to stand out against a dark background
        /// - Light mode: #323642
        /// - Dark mode: #EEEEEE
        public static let inverseSurface = Color(.Inverse.inverseSurface)

        /// Color for text and icons on top of inverse surface colors
        /// - Light mode: #EEEEEE
        /// - Dark mode: #323642
        public static let inverseOnSurface = Color(.Inverse.inverseOnSurface)

        /// Fixed color for error containers
        /// - Light/Dark mode: #FEF1F5
        public static let errorContainer = Color(.Fixed.errorContainer)

        /// Fixed color for warning containers
        /// - Light/Dark mode: #FEE4D3
        public static let warningContainer = Color(.Fixed.warningContainer)

        /// Fixed color for info containers
        /// - Light/Dark mode: #EDF5FE
        public static let infoContainer = Color(.Fixed.infoContainer)

        /// Fixed color for success containers
        /// - Light/Dark mode: #D9F6D5
        public static let successContainer = Color(.Fixed.successContainer)

        /// Fixed color for outlines on error elements
        /// - Light/Dark mode: #FF72A5
        public static let onErrorOutline = Color(.Fixed.onErrorOutline)

        /// Fixed color for outlines on warning elements
        /// - Light/Dark mode: #FEA754
        public static let onWarningOutline = Color(.Fixed.onWarningOutline)

        /// Fixed color for outlines on info elements
        /// - Light/Dark mode: #86D0FD
        public static let onInfoOutline = Color(.Fixed.onInfoOutline)

        /// Fixed color for outlines on success elements
        /// - Light/Dark mode: #88E47B
        public static let onSuccessOutline = Color(.Fixed.onSuccessOutline)

        /// Fixed color for content within error containers
        /// - Light/Dark mode: #B0024C
        public static let onErrorContainer = Color(.Fixed.onErrorContainer)

        /// Fixed color for content within warning containers
        /// - Light/Dark mode: #943511
        public static let onWarningContainer = Color(.Fixed.onWarningContainer)

        /// Fixed color for content within info containers
        /// - Light/Dark mode: #0171C4
        public static let onInfoContainer = Color(.Fixed.onInfoContainer)

        /// Fixed color for content within success containers
        /// - Light/Dark mode: #037900
        public static let onSuccessContainer = Color(.Fixed.onSuccessContainer)

        /// Gradient for connected status
        /// - Start: #4CB649
        /// - End: #5DD5FA
        public static let surfaceStatusConnected = PIAGradient(
            start: Color(.Fixed.Gradient.SurfaceStatusConnected.start),
            end: Color(.Fixed.Gradient.SurfaceStatusConnected.end)
        )

        /// Gradient for connecting status
        /// - Start: #E6B400
        /// - End: #F9CF01
        public static let surfaceStatusConnecting = PIAGradient(
            start: Color(.Fixed.Gradient.SurfaceStatusConnecting.start),
            end: Color(.Fixed.Gradient.SurfaceStatusConnecting.end)
        )

        /// Gradient for error status
        /// - Start: #B2352D
        /// - End: #F24458
        public static let surfaceStatusError = PIAGradient(
            start: Color(.Fixed.Gradient.SurfaceStatusError.start),
            end: Color(.Fixed.Gradient.SurfaceStatusError.end)
        )
    }

    /// Convenience accessor for PIA colors
    static var pia: PIA.Type { PIA.self }
}
