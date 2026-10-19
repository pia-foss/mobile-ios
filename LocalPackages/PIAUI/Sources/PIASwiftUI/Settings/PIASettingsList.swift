//
//  PIASettingsList.swift
//  PIASwiftUI
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
import SwiftUI

public struct PIASettingsList<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        List {
            content
        }
        .listStyle(.plain)
        .hideScrollContentBackground()
        .background(Color.pia.background.ignoresSafeArea())
    }
}

extension View {
    @ViewBuilder
    fileprivate func hideScrollContentBackground() -> some View {
        #if os(tvOS)
            self
        #else
            if #available(iOS 16, *) {
                scrollContentBackground(.hidden)
            } else {
                self
            }
        #endif
    }
}

#Preview {
    PIASettingsList {
        PIASettingsNavigationRow("'Connect' Siri Shortcut") {}
        PIASettingsNavigationRow("'Disconnect' Siri Shortcut", value: "Added") {}
        PIASettingsToggleRow("Show Service Communication Messages", isOn: .constant(true))
        PIASettingsToggleRow(
            "Show Geo-located Regions",
            description: "Regions whose servers are not physically in the country",
            isOn: .constant(false)
        )
        PIASettingsNavigationRow(
            "Reset settings to default",
            description: "This will reset all of the above settings to default."
        ) {}
    }
}
