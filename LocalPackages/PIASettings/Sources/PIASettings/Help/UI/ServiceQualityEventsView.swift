//
//  ServiceQualityEventsView.swift
//  PIASettings
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import PIADesignSystem
import PIALocalizations
import PIASwiftUI
import SwiftUI

public struct ServiceQualityEventsView: View, ViewWithTitle {
    private let loadEvents: @MainActor @Sendable () async -> [String]
    @State private var events: [String] = []

    public var navigationTitle: String { L10n.Settings.Service.Quality.Show.title }

    public init(loadEvents: @MainActor @Sendable @escaping () async -> [String]) {
        self.loadEvents = loadEvents
    }

    public var body: some View {
        ScrollView {
            if !events.isEmpty {
                Text(events.joined(separator: "\n\n"))
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundColor(.pia.onSurface)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(PIASpacing.s16)
                    .background(Color.pia.surfaceContainerPrimary)
                    .cornerRadius(PIASpacing.s8)
                    .padding(PIASpacing.s16)
            }
        }
        .background(Color.pia.background.ignoresSafeArea())
        .task { events = await loadEvents() }
    }
}

#Preview {
    ServiceQualityEventsView {
        [
            #"{"event_name":"VPN_CONNECTION_ATTEMPT","event_properties":{"vpn_protocol":"WireGuard"}}"#,
            #"{"event_name":"VPN_CONNECTION_ESTABLISHED","event_properties":{"vpn_protocol":"WireGuard"}}"#
        ]
    }
}
