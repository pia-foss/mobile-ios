//
//  PIACard.swift
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

extension View {
    /// Groups the content on a full-width, rounded surface card with the standard inner padding.
    public func piaCard() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
            .padding(PIASpacing.s16)
            .background(Color.pia.surfaceContainerPrimary)
            .clipShape(RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous))
    }
}

#Preview {
    VStack(spacing: PIASpacing.s16) {
        VStack(alignment: .leading, spacing: PIASpacing.s4) {
            Text("Username").typography(.caption1, color: .pia.onSurfaceContainerSecondary)
            Text("p1234567").typography(.subtitle1, color: .pia.onSurface)
        }
        .piaCard()

        Text("A card holding a single paragraph of body text.")
            .typography(.body2, color: .pia.onSurfaceContainerSecondary)
            .piaCard()
    }
    .padding(PIASpacing.s16)
    .background(Color.pia.background)
}
