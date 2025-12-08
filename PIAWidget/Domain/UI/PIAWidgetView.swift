//
//  PIAWidgetView.swift
//  PIAWidgetExtension
//
//  Created by Juan Docal on 2022-09-28.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct PIAWidgetView : View {

    @Environment(\.widgetFamily) var widgetFamily

    let entry: PIAWidgetProvider.Entry
    let widgetPersistenceDatasource: WidgetPersistenceDatasource

    init(
        entry: PIAWidgetProvider.Entry,
        widgetPersistenceDatasource: WidgetPersistenceDatasource
    ) {
        self.entry = entry
        self.widgetPersistenceDatasource = widgetPersistenceDatasource
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            let targetIconSize = widgetFamily == .systemMedium ? 100.0 : 50.0
            let targetPadding = widgetFamily == .systemMedium ? -25.0 : -9.0
            PIAIconView(iconSize: targetIconSize, padding: targetPadding)
            HStack {
                if widgetPersistenceDatasource.getIsTrustedNetwork() {
                    PIACircleVpnButton(color: Color("TrustedNetworkColor"))
                } else {
                    let targetColor = widgetPersistenceDatasource.getIsVPNConnected() ? "AccentColor" : "RedColor"
                    PIACircleVpnButton(color: Color(targetColor))
                }

                if widgetFamily == .systemMedium {
                    PIAWidgetVpnDetailsView(
                        vpnProtocol: widgetPersistenceDatasource.getVpnProtocol(),
                        port: widgetPersistenceDatasource.getVpnPort(),
                        socket: widgetPersistenceDatasource.getVpnSocket()
                    )
                }
            }

        }.widgetURL(URL(string: widgetFamily == .systemMedium ? "piavpn:view" : "piavpn:connect"))
        .background(Color("WidgetBackground"))
    }
}
