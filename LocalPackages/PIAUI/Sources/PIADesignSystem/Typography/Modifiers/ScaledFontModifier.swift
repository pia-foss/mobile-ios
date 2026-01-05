//
//  ScaledFontModifier.swift
//  PIADesignSystem
//
//  Created by Diego Trevisan on 09.12.25.
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

/// Applies scaled font based on typography style weight
struct ScaledFontModifier: ViewModifier {
    let weight: Font.Weight
    @ScaledMetric private var scaledSize: CGFloat

    init(baseSize: CGFloat, weight: Font.Weight) {
        self.weight = weight
        _scaledSize = ScaledMetric(wrappedValue: baseSize)
    }

    func body(content: Content) -> some View {
        content.font(
            .system(
                size: scaledSize,
                weight: weight,
                design: .default
            )
        )
    }
}
