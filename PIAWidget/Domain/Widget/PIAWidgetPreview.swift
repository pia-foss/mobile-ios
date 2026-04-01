//
//  PIAWidgetPreview.swift
//  PIAWidgetExtension
//
//  Created by Juan Docal on 2022-09-28.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

@available(iOS 17, *)
#Preview(as: .systemSmall, widget: {
    PIAWidget()
}, timeline: {
    WidgetInformation(
        date: Date(),
        connected: true,
        vpnProtocol: "IKEv2",
        vpnPort: "500",
        vpnSocket: "UDP"
    )
})

@available(iOS 17, *)
#Preview(as: .systemMedium, widget: {
    PIAWidget()
}, timeline: {
    WidgetInformation(
        date: Date(),
        connected: false,
        vpnProtocol: "WireGuard",
        vpnPort: "1443",
        vpnSocket: "UDP"
    )
})
