//
//  MainSettingsView.swift
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

import PIAAssetsMobile
import PIALocalizations
import PIASwiftUI
import SwiftUI

public struct MainSettingsView: View, ViewWithTitle {
    public enum Destination: CaseIterable, Sendable {
        case general
        case protocols
        case network
        case privacyFeatures
        case automation
        case help
    }

    private let values: [Destination: String]
    private let onSelect: @MainActor (Destination) -> Void

    public var navigationTitle: String { L10n.Menu.Item.settings }

    public init(values: [Destination: String] = [:], onSelect: @MainActor @escaping (Destination) -> Void) {
        self.values = values
        self.onSelect = onSelect
    }

    public var body: some View {
        SettingsList {
            ForEach(Destination.allCases, id: \.self) { destination in
                SettingsNavigationRow(
                    title: destination.title,
                    icon: destination.icon,
                    value: values[destination],
                    action: { onSelect(destination) }
                )
            }
        }
    }
}

extension MainSettingsView.Destination {
    fileprivate var title: String {
        switch self {
        case .general: L10n.Settings.Section.general
        case .protocols: L10n.Settings.Section.protocols
        case .network: L10n.Settings.Section.network
        case .privacyFeatures: L10n.Settings.Section.privacyFeatures
        case .automation: L10n.Settings.Section.automation
        case .help: L10n.Settings.Section.help
        }
    }

    fileprivate var icon: Image {
        switch self {
        case .general: Asset.Piax.Settings.iconGeneral.swiftUIImage
        case .protocols: Asset.Piax.Settings.iconProtocols.swiftUIImage
        case .network: Asset.Piax.Settings.iconNetwork.swiftUIImage
        case .privacyFeatures: Asset.Piax.Settings.iconPrivacy.swiftUIImage
        case .automation: Asset.Piax.Settings.iconAutomation.swiftUIImage
        case .help: Asset.Piax.Settings.iconAbout.swiftUIImage
        }
    }
}
