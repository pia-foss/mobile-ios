//
//  ActionButton.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 9/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct ActionButton: View {
    var title: String
    var action: () -> Void
    @FocusState private var isFocus: Bool

    init(title: String, action: @escaping () -> Void, isFocus: Bool = false) {
        self.title = title
        self.action = action
        self.isFocus = isFocus
    }

    var body: some View {
        Button(
            action: action,
            label: {
                ZStack {
                    if isFocus {
                        Color.pia_primary
                    } else {
                        Color.pia_surface_container_secondary
                    }
                    Text(title)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .foregroundStyle(isFocus ? Color.pia_on_primary : Color.pia_on_surface)
                }
            }
        )
        .buttonStyle(.card)
        .focused($isFocus)
    }
}
