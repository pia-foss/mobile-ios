//
//  RegionsListItemButton.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/25/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct RegionsListItemButton: View {
    
    typealias ButtonAction = () -> Void
    let onRegionItemSelected: ButtonAction
    @FocusState var buttonFocused: Bool
    
    let iconName: String
    let title: String
    var subtitle: String?
    let favoriteIconName: String
    let contextMenuItem: ContextMenuItem
    
    
    var body: some View {
        Button {
            onRegionItemSelected()
        } label: {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    flagIconImage
                    Spacer()
                    favoriteIconImage
                }
                detailsView
            }
            .padding(20)
            .frame(height: 196)
            
        }
        .background(buttonFocused ? Color.pia_primary : Color.pia_surface_container_secondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .focused($buttonFocused)
        .buttonStyle(.borderless)
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
        let iconName: String
        var body: some View {
            HStack {
                Text(title)
                Image(iconName)
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
        switch favoriteIconName {
        case "favorite-filled-icon": return Color.pia_error
        default: return
            buttonFocused ? Color.black : Color.pia_outline_variant_primary
        }
    }
    
    var flagIconImage: some View {
        Image(iconName)
            .resizable()
            .scaledToFill()
            .frame(width: 75, height: 75)
            .clipShape(Circle())
            .overlay(
                RoundedRectangle(cornerRadius: 40).stroke(Color.white, lineWidth: 2)
            )
    }
    
    var favoriteIconImage: some View {
        Image(favoriteIconName)
            .resizable()
            .frame(width: 54, height: 54)
            .foregroundColor(favoriteIconForegroundColor)
    }
    
    
    var detailsView: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 31, weight: .medium))
                .multilineTextAlignment(.leading)
                .foregroundColor(buttonFocused ? Color.black : Color.pia_on_surface_container_secondary)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2, reservesSpace: true)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .italic()
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

