//
//  TypographyStyle.swift
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

/// Typography styles for PIA VPN design system.
///
/// Defines semantic typography styles with consistent font sizes, weights, and line heights.
/// Use with `.typography()` modifier for proper line height application.
///
/// Example:
/// ```swift
/// Text("Main Header").typography(.title1)
/// Text("Section").typography(.title2)
/// ```
public enum TypographyStyle {
    /// SF Pro Bold, 22pt, line height 28pt
    case title1

    /// SF Pro Semibold, 20pt, line height 25pt
    case title2

    /// SF Pro Regular, 20pt, line height 25pt
    case title3

    /// SF Pro Semibold, 17pt, line height 22pt
    case subtitle1

    /// SF Pro Semibold, 15pt, line height 20pt
    case subtitle2

    /// SF Pro Semibold, 13pt, line height 18pt
    case subtitle3

    /// SF Pro Regular, 17pt, line height 22pt
    case body1

    /// SF Pro Regular, 15pt, line height 20pt
    case body2

    /// SF Pro Regular, 17pt, line height 22pt
    case button1

    /// SF Pro Regular, 15pt, line height 20pt
    case button2

    /// SF Pro Regular, 12pt, line height 16pt
    case caption1

    /// SF Pro Regular, 11pt, line height 13pt
    case caption2

    /// SF Pro Regular, 12pt, line height 16pt (underlined)
    case caption3
}

// MARK: - TypographyStyle Properties

extension TypographyStyle {
    /// Font size in points
    var fontSize: CGFloat {
        switch self {
        case .title1:       22
        case .title2:       20
        case .title3:       20
        case .subtitle1:    17
        case .subtitle2:    15
        case .subtitle3:    13
        case .body1:        17
        case .body2:        15
        case .button1:      17
        case .button2:      15
        case .caption1:     12
        case .caption2:     11
        case .caption3:     12
        }
    }

    /// Line height in points
    var lineHeight: CGFloat {
        switch self {
        case .title1:       28
        case .title2:       25
        case .title3:       25
        case .subtitle1:    22
        case .subtitle2:    20
        case .subtitle3:    18
        case .body1:        22
        case .body2:        20
        case .button1:      22
        case .button2:      20
        case .caption1:     16
        case .caption2:     13
        case .caption3:     16
        }
    }

    /// Font weight for this typography style (used for Dynamic Type scaling)
    var fontWeight: Font.Weight {
        switch self {
        case .title1:
            .bold
        case .title2, .subtitle1, .subtitle2, .subtitle3:
            .semibold
        case .title3, .body1, .body2, .button1, .button2, .caption1, .caption2, .caption3:
            .regular
        }
    }

    /// Line spacing (lineHeight - fontSize)
    var lineSpacing: CGFloat {
        lineHeight - fontSize
    }

    /// Whether this style should have underline decoration
    var hasUnderline: Bool {
        switch self {
        case .caption3:
            true
        default:
            false
        }
    }

    /// Returns the SwiftUI Font for this typography style
    var font: Font {
        .sfPro(
            size: fontSize,
            weight: fontWeight
        )
    }
}
