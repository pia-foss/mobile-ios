//
//  ReadMoreView.swift
//  PIAConsent
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
import SwiftUI

public struct ReadMoreView: View {
    @ObservedObject private var viewModel: ReadMoreViewModel

    public init(viewModel: ReadMoreViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            closeButton

            ScrollView {
                Text(viewModel.description)
                    .typography(.body2, color: .pia.onSurfaceContainerSecondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 29)
                    .padding(.bottom, 24)
            }
        }
        .background(Color.pia.background.ignoresSafeArea())
    }

    private var closeButton: some View {
        HStack {
            Button(action: viewModel.closeButtonWasTapped) {
                Asset.iconClose.swiftUIImage
                    .renderingMode(.template)
                    .foregroundColor(.pia.onSurfaceContainerSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(viewModel.closeAccessibilityLabel))

            Spacer()
        }
        .padding(.leading, 8)
        .padding(.top, 8)
    }
}

#Preview {
    ReadMoreView(viewModel: ReadMoreViewModel())
}
