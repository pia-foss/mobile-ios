//
//  ButtonStyles.swift
//  PIADesignSystem
//
//  Created by Mario on 28/04/2026.
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

private struct PrimaryButtonStyle: ButtonStyle {
    let radius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .typography(.button1, color: .white)
            .padding(13)
            .background(Color.pia.primary)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

public extension View {
    func primaryButton(radius: CGFloat = 12) -> some View {
        return buttonStyle(PrimaryButtonStyle(radius: radius))
    }
}
