//
//  ActionButton.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 9/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct ActionButtonStyle {
    var focusedColor: Color = Color.pia_primary
    var focusedTitleColor: Color = Color.pia_on_primary
    var unfocusedColor: Color = Color.pia_surface_container_secondary
    var unfocusedTitleColor: Color = Color.pia_on_surface
    var titleAlignment: Alignment = .center
    var titlePadding: EdgeInsets = EdgeInsets()
}

struct ActionButton: View {
    private let title: String
    private let action: () -> Void
    @FocusState private var isFocus: Bool
    private let style: ActionButtonStyle

    init(title: String, style: ActionButtonStyle = ActionButtonStyle(), action: @escaping () -> Void, isFocus: Bool = false) {
        self.title = title
        self.action = action
        self.style = style
        self.isFocus = isFocus
    }

    var body: some View {
        Button(
            action: action,
            label: {
                ZStack {
                    if isFocus {
                        style.focusedColor
                    } else {
                        style.unfocusedColor
                    }
                    Text(title)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: style.titleAlignment)
                        .foregroundStyle(isFocus ? style.focusedTitleColor : style.unfocusedTitleColor)
                        .padding(style.titlePadding)
                }
            }
        )
        .buttonStyle(.card)
        .focused($isFocus)
    }
}
