//
//  RegionListStyle.swift
//  PIARegionList
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

#if os(iOS)
    import PIADesignSystem
    import SwiftUI
    import UIKit

    /// The legacy region palette, matching `Theme.current` in the app.
    struct RegionListStyle {
        let colorScheme: ColorScheme

        private var isDark: Bool { colorScheme == .dark }

        var background: Color { Color(isDark ? UIColor.piaGrey6 : UIColor.piaGrey1) }
        var title: Color { Color(isDark ? UIColor.white : UIColor.piaGrey6) }
        var divider: Color { isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.2) }
        var secondary: Color { Color(UIColor.piaGrey4) }

        static let rowHeight: CGFloat = 50
        static let animationDuration = 0.3

        static func font(size: CGFloat) -> Font {
            Font(UIFont.regularFontWith(size: size) ?? .systemFont(ofSize: size))
        }

        static func pingColor(_ pingTime: Int) -> Color {
            switch pingTime {
            case ..<100: Color(UIColor.piaGreenDark20)
            case ..<200: Color(UIColor.piaOrange)
            default: Color(UIColor.piaRed)
            }
        }
    }
#endif
