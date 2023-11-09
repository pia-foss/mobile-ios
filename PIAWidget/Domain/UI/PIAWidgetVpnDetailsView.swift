//
//  PIAWidgetVpnDetailsView.swift
//  PIAWidgetExtension
//
//  Created by Juan Docal on 2022-09-28.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

internal struct PIAWidgetVpnDetailsView: View {

    private let viewTrailingPadding: CGFloat = 40.0

    internal let vpnProtocol: String
    internal let port: String
    internal let socket: String

    init(vpnProtocol: String, port: String, socket: String) {
        self.vpnProtocol = vpnProtocol
        self.port = port
        self.socket = socket
    }

    var body: some View {
        return VStack {
            PIAWidgetVpnDetaislRow(iconName: "icon-protocol", text: vpnProtocol)
            PIAWidgetVpnDetaislRow(iconName: "icon-port", text: port)
            PIAWidgetVpnDetaislRow(iconName: "icon-socket", text: socket)
        }.padding(.trailing, viewTrailingPadding)
    }
}
