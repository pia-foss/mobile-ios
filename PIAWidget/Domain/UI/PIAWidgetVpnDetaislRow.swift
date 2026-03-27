//
//  PIAWidgetVpnDetaislRow.swift
//  PIAWidgetExtension
//
//  Created by Juan Docal on 2022-09-29.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

internal struct PIAWidgetVpnDetaislRow: View {

    private let fontSize: CGFloat = 14.0
    private let iconsSize: CGFloat = 25.0
    private let rowSpacing: CGFloat = 0.0

    internal let icon: Image
    internal let text: String

    init(icon: Image, text: String) {
        self.icon = icon
        self.text = text
    }

    var body: some View {
        HStack(alignment: .center, spacing: rowSpacing) {
            icon
                .resizable()
                .frame(width: iconsSize, height: iconsSize, alignment: .leading)
            Spacer()
            Text(text)
                .font(.system(size: fontSize))
                .foregroundColor(Color("FontColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
