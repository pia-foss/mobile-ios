//
//  RegionsListItemButton.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/25/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

typealias ButtonAction = () -> Void

struct RegionsListItemButton: View {
    let onRegionItemSelected: ButtonAction
    @FocusState var buttonFocused: Bool

    let iconImage: Image
    var highlightedIconImage: Image?
    let title: String
    var subtitle: String?
    let favoriteIconImage: Image
    var isFavorite: Bool
    let contextMenuItem: ContextMenuItem

    var body: some View {
        Button {
            onRegionItemSelected()
        } label: {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    if buttonFocused {
                        highlightedFlagIconView
                    } else {
                        flagIconView
                    }

                    Spacer()
                    favoriteIconView
                }
                detailsView
            }
            .padding(20)
            .frame(height: 196)

        }
        .background(buttonFocused ? Color.pia_primary : Color.pia_surface_container_secondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .focused($buttonFocused)
        .buttonStyle(BasicButtonStyle())
        .buttonBorderShape(.roundedRectangle(radius: 20))

        .contextMenu(menuItems: {
            Button {
                contextMenuItem.action()
            } label: {
                contextMenuItem.label
                    .foregroundColor(favoriteIconForegroundColor)
            }
        })
    }
}

// MARK: - Context Menu

extension RegionsListItemButton {
    struct ContextMenuLabel: View {
        let title: String
        let iconImage: Image
        var body: some View {
            HStack {
                Text(title)
                iconImage
                    .resizable()
                    .frame(width: 52, height: 52)
                    .foregroundColor(Color.pia_outline_variant_primary)
            }
        }
    }

    enum ContextMenuItem {
        case item(label: ContextMenuLabel, action: ButtonAction)

        var label: ContextMenuLabel {
            switch self {
            case .item(let label, _):
                return label
            }
        }

        var action: ButtonAction {
            switch self {
            case .item(_, let action):
                return action
            }
        }

    }
}

// MARK: - UI Elements

extension RegionsListItemButton {
    var favoriteIconForegroundColor: Color {
        isFavorite ? Color.pia_error : (buttonFocused ? Color.black : Color.pia_outline_variant_primary)
    }

    var flagIconView: some View {
        iconImage
            .resizable()
            .scaledToFill()
            .frame(width: 75, height: 75)
            .clipShape(Circle())
            .overlay(
                RoundedRectangle(cornerRadius: 40).stroke(Color.white, lineWidth: 2)
            )
    }

    var highlightedFlagIconView: some View {
        (highlightedIconImage ?? iconImage)
            .resizable()
            .scaledToFill()
            .frame(width: 75, height: 75)
            .clipShape(Circle())
            .overlay(
                RoundedRectangle(cornerRadius: 40).stroke(Color.white, lineWidth: 2)
            )
    }

    var favoriteIconView: some View {
        favoriteIconImage
            .resizable()
            .frame(width: 54, height: 54)
            .foregroundColor(favoriteIconForegroundColor)
    }

    var detailsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 31, weight: .medium))
                .multilineTextAlignment(.leading)
                .foregroundColor(buttonFocused ? Color.pia_on_primary : Color.pia_on_surface_container_primary)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(1)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 23, weight: .medium))
                    .italic()
                    .foregroundColor(buttonFocused ? Color.pia_on_primary : Color.pia_on_surface_container_primary)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
            }
        }
    }
}
