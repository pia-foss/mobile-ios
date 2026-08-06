//
//  ConsentView.swift
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

public struct ConsentView: View {
    private let viewModel: ConsentViewModel
    @State private var isReadMorePresented = false

    public init(viewModel: ConsentViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    content
                        .frame(maxWidth: 440)
                }
                .frame(width: proxy.size.width)
                .frame(minHeight: proxy.size.height)
            }
        }
        .background(Color.pia.background.ignoresSafeArea())
        .sheet(isPresented: $isReadMorePresented) {
            ConsentFactory.makeReadMoreView(onClose: { isReadMorePresented = false })
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            illustration

            Text(viewModel.title)
                .typography(.title3, color: .pia.onBackground)
                .padding(.top, 10)

            Text(viewModel.message)
                .typography(.body2, color: .pia.onSurfaceContainerSecondary)
                .padding(.top, 19)

            readMoreButton
                .padding(.top, 5)

            acceptButton
                .padding(.top, 19)

            noThanksButton
                .padding(.top, 10)

            Text(viewModel.footer)
                .typography(.caption1, color: .pia.onSurfaceContainerSecondary)
                .padding(.top, 10)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 29)
        .padding(.vertical, 24)
    }

    private var illustration: some View {
        Asset.imageDocumentConsent.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 100)
            .accessibilityHidden(true)
    }

    private var readMoreButton: some View {
        Button(action: { isReadMorePresented = true }) {
            Text(viewModel.readMoreTitle)
                .underline()
                .typography(.body2, color: .pia.onSurfaceContainerSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("id.consent.readMore")
    }

    private var acceptButton: some View {
        Button(action: viewModel.acceptButtonWasTapped) {
            Text(viewModel.acceptTitle)
                .typography(.button2, color: .pia.onPrimary)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.pia.primary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("id.consent.accept")
    }

    private var noThanksButton: some View {
        Button(action: viewModel.noThanksButtonWasTapped) {
            Text(viewModel.noThanksTitle)
                .typography(.button2, color: .pia.primary)
                .frame(maxWidth: .infinity, minHeight: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.pia.primary, lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("id.consent.noThanks")
    }
}

#Preview {
    ConsentFactory.makeConsentView()
}
