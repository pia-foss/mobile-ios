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

struct PIAWidgetPreview: PreviewProvider {

    static var previews: some View {
        let widgetPersistenceDatasource = WidgetUserDefaultsDatasource()
        PIAWidgetView(
            entry: WidgetInformation(
                date: Date(),
                connected: true,
                vpnProtocol: "IKEv2",
                vpnPort: "500",
                vpnSocket: "UDP"
            ),
            widgetPersistenceDatasource: widgetPersistenceDatasource
        ).previewContext(WidgetPreviewContext(family: .systemSmall))
        PIAWidgetView(
            entry: WidgetInformation(
                date: Date(),
                connected: false,
                vpnProtocol: "WireGuard",
                vpnPort: "1443",
                vpnSocket: "UDP"
            ),
            widgetPersistenceDatasource: widgetPersistenceDatasource
        ).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
