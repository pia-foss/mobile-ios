//
//  PIAIconView.swift
//  PIAWidgetExtension
//
//  Created by Juan Docal on 2022-09-28.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

internal struct PIAIconView: View {

    private let iconRotation: CGFloat = -35.0
    private let iconSize: CGFloat
    private let padding: CGFloat

    init(iconSize: CGFloat, padding: CGFloat) {
        self.iconSize = iconSize
        self.padding = padding
    }

    var body: some View {
        return Image("robot")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: iconSize, height: iconSize, alignment: .center)
            .rotationEffect(Angle(degrees: iconRotation))
            .padding(padding)
    }
}
