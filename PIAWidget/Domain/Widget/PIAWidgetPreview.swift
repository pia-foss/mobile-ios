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
#Preview(
    as: .systemSmall,
    widget: {
        PIAWidget()
    },
    timeline: {
        WidgetInformation(
            date: Date(),
            connected: true,
            vpnProtocol: "WireGuard",
            vpnPort: "1337",
            vpnSocket: "UDP"
        )
    })

@available(iOS 17, *)
#Preview(
    as: .systemMedium,
    widget: {
        PIAWidget()
    },
    timeline: {
        WidgetInformation(
            date: Date(),
            connected: false,
            vpnProtocol: "WireGuard",
            vpnPort: "1443",
            vpnSocket: "UDP"
        )
        WidgetInformation(
            date: Date(),
            connected: true,
            vpnProtocol: "Automatic (WireGuard®)",
            vpnPort: "1337",
            vpnSocket: "UDP"
        )
        // The longest localized Automatic label.
        WidgetInformation(
            date: Date(),
            connected: true,
            vpnProtocol: "Автоматически (WireGuard®)",
            vpnPort: "8080",
            vpnSocket: "TCP"
        )
    })
