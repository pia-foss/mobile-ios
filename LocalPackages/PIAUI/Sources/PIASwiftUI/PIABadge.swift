//
//  PIABadge.swift
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

import PIADesignSystem
import SwiftUI

/// A small pill label used to call out a value or a status.
///
/// Example:
/// ```swift
/// PIABadge(title, background: .pia.onWarningOutline, foreground: .pia.onSurface)
/// ```
public struct PIABadge: View {
    private let title: String
    private let background: Color
    private let foreground: Color

    public init(_ title: String, background: Color, foreground: Color) {
        self.title = title
        self.background = background
        self.foreground = foreground
    }

    public var body: some View {
        Text(title)
            .typography(.caption1, color: foreground)
            .padding(.horizontal, PIASpacing.s8)
            .padding(.vertical, PIASpacing.s4)
            .background(
                RoundedRectangle(cornerRadius: PIASpacing.s4, style: .continuous)
                    .fill(background)
            )
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: PIASpacing.s8) {
        PIABadge("Best Value", background: .pia.onWarningOutline, foreground: .pia.onSurface)
        PIABadge("7-day Free Trial", background: .pia.successContainer, foreground: .pia.onSuccessContainer)
    }
    .padding(PIASpacing.s24)
    .background(Color.pia.background)
}
