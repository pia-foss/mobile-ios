//
//  PIACircleVpnButton.swift
//  PIAWidgetExtension
//
//  Created by Juan Docal on 2022-09-28.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

internal struct PIACircleVpnButton: View {

    internal let color: Color

    private let buttonSize: CGFloat = 40.0
    private let strokeWidth: CGFloat = 8.0

    @State private var outerCircle: CGFloat
    @State private var innerCircle: CGFloat

    init(color: Color) {
        self.color = color
        self.outerCircle = buttonSize
        self.innerCircle = buttonSize - strokeWidth
    }

    var body: some View {
        return Circle()
            .strokeBorder(Color("BorderColor"), lineWidth: strokeWidth * 0.75)
            .background(Circle()
                .strokeBorder(color, lineWidth: strokeWidth)
                .background(Image("vpn-button")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(color)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonSize, height: buttonSize)
                    .padding(0.0)
                )
            )
            .padding(buttonSize / 2.0)
    }
}
