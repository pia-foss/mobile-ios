//
//  SettingsButtonView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct SettingsButtonView: View {
    
    @FocusState var isButtonFocused: Bool
    
    let title: String
    var subtitle: String?
    var style: RightItemStyle = .none
    let buttonAction: ButtonAction
    
    var body: some View {
        if let subtitle {
            settingsButton
        } else {
            settingsButton
                .frame(height: Spacing.settingsButtonHeight)
        }
        
    }
    
    var settingsButton: some View {
        Button {
            buttonAction()
        } label: {
            HStack {
                leadingContent
                Spacer()
                trailingContent
            }
        }
        .focused($isButtonFocused)
        .buttonStyle(BasicButtonStyle())
        .buttonBorderShape(.roundedRectangle)
        .background(
            isButtonFocused ?
            Color.pia_primary :
            Color.pia_surface_container_secondary
        )
        .clipShape(RoundedRectangle(cornerSize: Spacing.listItemCornerSize))
    }
    
    var leadingContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 38, weight: .medium))
                .foregroundColor(isButtonFocused ? .pia_on_primary : .pia_on_surface)
            
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 25, weight: .medium))
                    .foregroundColor(isButtonFocused ? .pia_on_primary : .pia_on_surface)
                    .lineLimit(nil)
            }
        }
        .padding(.horizontal, Spacing.settingsButtonHorizontalPadding)
    }
    
    var trailingContent: some View {
        VStack {
            switch style {
            case .rightChevron:
                Image(systemName: "chevron.right")
                    .foregroundColor(isButtonFocused ? .pia_on_primary : .pia_on_surface)
            case .rightText(let content):
                Text(content)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundColor(isButtonFocused ? .pia_on_primary : .pia_on_surface)
            case .none:
                Spacer()
            }
        }
    }
    
}

// MARK: - SettingsButtonView Style

extension SettingsButtonView {
    enum RightItemStyle: Equatable {
        case none
        case rightChevron
        case rightText(content: String)
        
        static func == (lhs: SettingsButtonView.RightItemStyle, rhs: SettingsButtonView.RightItemStyle) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none):
                return true
            case (.rightChevron, .rightChevron):
                return true
            case (.rightText(content: let lhsText), .rightText(content: let rhsText)):
                return lhsText == rhsText
            default:
                return false
            }
        }
    }
    
    
}
