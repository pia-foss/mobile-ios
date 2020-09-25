//
//  PIAWidget.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 24/09/2020.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> WidgetContent {
        WidgetContent(date: Date(),
                      connected: false,
                      vpnProtocol: "IPSec (IKEv2)",
                      vpnPort: "500",
                      vpnSocket: "UDP")
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> ()) {
        let entry: WidgetContent
        entry = WidgetContent(date: Date(),
                              connected: WidgetUtils.isVPNConnected,
                              vpnProtocol: WidgetUtils.vpnProtocol,
                              vpnPort: WidgetUtils.vpnPort,
                              vpnSocket: WidgetUtils.vpnSocket)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [WidgetContent] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = WidgetContent(date: entryDate,
                                      connected: WidgetUtils.isVPNConnected,
                                      vpnProtocol: WidgetUtils.vpnProtocol,
                                      vpnPort: WidgetUtils.vpnPort,
                                      vpnSocket: WidgetUtils.vpnSocket)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct PIAWidgetEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: Provider.Entry
    
    var body: some View {

        ZStack(alignment: .bottomTrailing) {
                
                Image("robot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: widgetFamily == .systemMedium ? 100 : 50, height: widgetFamily == .systemMedium ? 100 : 50, alignment: .center)
                    .rotationEffect(Angle(degrees: -35.0))
                    .padding(widgetFamily == .systemMedium ? -25 : -9)

            HStack {

                Circle()
                    .strokeBorder(Color("BorderColor"),lineWidth: 6)
                   .background(Circle()
                                .strokeBorder(Color(WidgetUtils.isVPNConnected ? "AccentColor" : "RedColor"),lineWidth: 8)
                                .background(Image("vpn-button")
                                                .resizable()
                                                .renderingMode(.template).foregroundColor(Color(WidgetUtils.isVPNConnected ? "AccentColor" : "RedColor"))
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40, alignment: .center)
                                                .padding(0)))
                    .padding(20)
                
                if widgetFamily == .systemMedium {
                    VStack {
                        HStack(alignment: .center, spacing: 0) {
                            Image("icon-protocol").resizable().frame(width: 25, height: 25, alignment: .leading)
                            Spacer()
                            Text(WidgetUtils.vpnProtocol).font(.system(size: 14)).foregroundColor(Color("FontColor")).frame(maxWidth: .infinity, alignment: .leading)
                        }
                        HStack(alignment: .center, spacing: 0) {
                            Image("icon-port").resizable().frame(width: 25, height: 25, alignment: .leading)
                            Spacer()
                            Text(WidgetUtils.vpnPort).font(.system(size: 14)).foregroundColor(Color("FontColor")).frame(maxWidth: .infinity, alignment: .leading)
                        }
                        HStack(alignment: .center, spacing: 0) {
                            Image("icon-socket").resizable().frame(width: 25, height: 25, alignment: .leading)
                            Spacer()
                            Text(WidgetUtils.vpnSocket).font(.system(size: 14)).foregroundColor(Color("FontColor")).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }.padding(.trailing, 40)

                }

            }

        }.widgetURL(URL(string: "piavpn:connect"))
        .background(Color("WidgetBackground"))
            
    }

}

@main
struct PIAWidget: Widget {
    let kind: String = "PIAWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PIAWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("PIA VPN")
        .supportedFamilies([.systemSmall, .systemMedium])

    }
}

struct PIAWidget_Previews: PreviewProvider {
    static var previews: some View {
        PIAWidgetEntryView(entry: WidgetContent(date: Date(), connected: true, vpnProtocol: "IKEv2", vpnPort: "500", vpnSocket: "UDP"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        PIAWidgetEntryView(entry: WidgetContent(date: Date(), connected: false, vpnProtocol: "WireGuard", vpnPort: "1443", vpnSocket: "UDP"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
