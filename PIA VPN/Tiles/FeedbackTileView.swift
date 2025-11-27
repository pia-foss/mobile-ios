//
//  AvailableTiles.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 25/11/2019.
//  Copyright © 2020 Private Internet Access, Inc.
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
import PIALibrary

@available(iOS 15.0, *)
struct FeedbackTileView: View {
    @Environment(\.colorScheme) var colorScheme

    private let ratingManager: RatingManagerProtocol = RatingManager.shared

    private var cardBackgroungColor: UIColor {
        colorScheme == .dark ? .piaGrey8 : .piaGrey2
    }

    private var buttonBackgroundColor: UIColor {
        colorScheme == .dark ? .piaGrey6 : .white
    }

    var body: some View {
        HStack {
            SwiftUI.Image(uiImage: Asset.Images.imageAccessCard.image)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 100)
            
            Spacer()
            
            VStack(alignment: .center, spacing: 12) {
                Text(L10n.Localizable.Tiles.Feedback.title)
                    .font(Font(TextStyle.textStyle24.font! as CTFont))
                    .foregroundStyle(.primary)
                
                HStack(alignment: .center, spacing: 12) {
                    rateButton(
                        image: .init(uiImage: Asset.Images.iconThumbsDown.image),
                        action: ratingManager.handleNegativeRating
                    )

                    rateButton(
                        image: .init(uiImage: Asset.Images.iconThumbsUp.image),
                        action: ratingManager.handlePositiveRating
                    )
                }
            }
            
            Spacer()
            
            // Close button
            VStack {
                Button(action: ratingManager.dismissFeedbackCard) {
                    SwiftUI.Image("icon-close")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .padding(6)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 15)
        .background(Color(uiColor: cardBackgroungColor))
    }

    @ViewBuilder
    @available(iOS 15.0, *)
    private func rateButton(
        image: SwiftUI.Image,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            image
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .frame(width: 56, height: 56)
        .background(Color(uiColor: buttonBackgroundColor))
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

@available(iOS 15.0, *)
#Preview {
    ScrollView {
        FeedbackTileView()
    }
}
