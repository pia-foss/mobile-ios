//
//  PaywallCloseButton.swift
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

import PIAAssetsMobile
import PIADesignSystem
import PIALocalizations
import SwiftUI

/// The corner dismiss control.
struct PaywallCloseButton: View {
    private enum Metrics {
        static let glyphSize: CGFloat = 24
        static let tapTarget: CGFloat = 44
    }

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Asset.Piax.Global.iconCloseSmall.swiftUIImage
                .renderingMode(.template)
                .resizable()
                .frame(width: Metrics.glyphSize, height: Metrics.glyphSize)
                .foregroundColor(.pia.onSurfaceContainerPrimary)
                .frame(width: Metrics.tapTarget, height: Metrics.tapTarget)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(L10n.Signup.Paywall.Accessibility.close)
    }
}

#Preview {
    PaywallCloseButton {}
        .padding(PIASpacing.s8)
        .background(Color.pia.background)
}
