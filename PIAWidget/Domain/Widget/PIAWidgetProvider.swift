//
//  PIAWidgetProvider.swift
//  PIAWidgetExtension
//
//  Created by Juan Docal on 2022-09-28.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation
import WidgetKit

struct PIAWidgetProvider: TimelineProvider {

    let widgetPersistenceDatasource: WidgetPersistenceDatasource

    init(widgetPersistenceDatasource: WidgetPersistenceDatasource) {
        self.widgetPersistenceDatasource = widgetPersistenceDatasource
    }

    func placeholder(in context: Context) -> WidgetInformation {
        WidgetInformation(
            date: Date(),
            connected: false,
            vpnProtocol: "IPSec (IKEv2)",
            vpnPort: "500",
            vpnSocket: "UDP"
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (WidgetInformation) -> ()
    ) {
        let entry: WidgetInformation
        entry = WidgetInformation(
            date: Date(),
            connected: widgetPersistenceDatasource.getIsVPNConnected(),
            vpnProtocol: widgetPersistenceDatasource.getVpnProtocol(),
            vpnPort: widgetPersistenceDatasource.getVpnPort(),
            vpnSocket: widgetPersistenceDatasource.getVpnSocket()
        )
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<WidgetInformation>) -> ()
    ) {
        var entries: [WidgetInformation] = []

        // Generate a timeline consisting of five entries an hour apart,
        // starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(
                byAdding: .hour,
                value: hourOffset,
                to: currentDate
            )!
            let entry = WidgetInformation(
                date: entryDate,
                connected: widgetPersistenceDatasource.getIsVPNConnected(),
                vpnProtocol: widgetPersistenceDatasource.getVpnProtocol(),
                vpnPort: widgetPersistenceDatasource.getVpnPort(),
                vpnSocket: widgetPersistenceDatasource.getVpnSocket()
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
