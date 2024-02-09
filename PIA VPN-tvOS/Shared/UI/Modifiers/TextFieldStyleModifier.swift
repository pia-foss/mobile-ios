//
//  TextFieldStyleModifier.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 9/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct TextFieldStyleModifier: TextFieldStyle {
    @FocusState var focus: Bool
    let textAlignment: TextAlignment

    init(textAlignment: TextAlignment = .center) {
        self.textAlignment = textAlignment
    }

    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {
            configuration
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(textAlignment)
                .focused($focus)
        }
    }
}
