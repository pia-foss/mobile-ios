//
//  ProtocolSettingsCoordinator.swift
//  PIA VPN
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

import Combine
import CoreArchitecture
import PIALibrary
import PIASettings
import UIKit

final class ProtocolSettingsCoordinator: @MainActor FlowCoordinator {
    private weak var parent: UINavigationController?
    private weak var pendingPreferences: Client.Preferences.Editable?
    private weak var settingsDelegate: SettingsDelegate?
    private let subject = PassthroughSubject<Void, Never>()

    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(
        parent: UINavigationController,
        pendingPreferences: Client.Preferences.Editable,
        settingsDelegate: SettingsDelegate
    ) {
        self.parent = parent
        self.pendingPreferences = pendingPreferences
        self.settingsDelegate = settingsDelegate
    }

    @MainActor
    func start() {
        guard let parent else {
            subject.send(completion: .finished)
            return
        }

        let view = ProtocolSettingsView(
            dependencies: .init(
                loadPreferences: { [weak self] in
                    Self.preferences(from: self?.pendingPreferences ?? Client.preferences.editable())
                },
                loadOptions: {
                    let ports = Client.providers.serverProvider.currentServersConfiguration.ovpnPorts
                    return .init(
                        udpPorts: ports.udp,
                        tcpPorts: ports.tcp,
                        ciphers: AppConstants.OpenVPNCrypto.allCases.map(\.rawValue),
                        isCipherEditable: Flags.shared.enablesEncryptionSettings
                    )
                },
                preferencesChanges: {
                    AsyncStream { continuation in
                        let task = Task {
                            for await _ in NotificationCenter.default.notifications(named: .PIASettingsHaveChanged) {
                                continuation.yield()
                            }
                        }
                        continuation.onTermination = { _ in task.cancel() }
                    }
                },
                setVPNProtocol: { [weak self] in self?.setVPNProtocol($0) },
                setTransport: { [weak self] transport in
                    self?.settingsDelegate?.updateSocketType(socketType: transport.socketType?.rawValue)
                    Macros.postNotification(.PIASettingsHaveChanged)
                },
                setRemotePort: { [weak self] port in
                    self?.settingsDelegate?.updateRemotePort(port: port)
                    Macros.postNotification(.PIASettingsHaveChanged)
                },
                setCipher: { [weak self] cipher in
                    self?.settingsDelegate?.updateDataEncryption(encryption: cipher)
                    Macros.postNotification(.PIASettingsHaveChanged)
                },
                setUsesSmallPackets: { [weak self] isOn in
                    self?.pendingPreferences?.useSmallPackets = isOn
                    self?.settingsDelegate?.savePreferences()
                },
            )
        )
        let host = NavigationHostingController(rootView: view) { [subject] in
            subject.send(completion: .finished)
        }
        parent.pushViewController(host, animated: true)
    }

    @MainActor
    private func setVPNProtocol(_ vpnProtocol: ProtocolSettings.VPNProtocol) {
        pendingPreferences?.vpnType = vpnProtocol.vpnType.rawValue
        settingsDelegate?.updateSetting(ProtocolsSections.protocolSelection, withValue: nil)
        Macros.postNotification(.PIASettingsHaveChanged)
        Macros.postNotification(.RefreshSettings)
    }

    private static func preferences(from preferences: Client.Preferences.Editable) -> ProtocolSettings.Preferences {
        .init(
            vpnProtocol: .init(SelectableVPNProtocol.resolved(fromStored: preferences.vpnType)),
            transport: .init(AppConstants.OpenVPNSocketType(rawValue: preferences.openVPNSocketType ?? "")),
            remotePort: UInt16(exactly: preferences.openVPNPort) ?? ProtocolSettings.automaticPort,
            cipher: preferences.openVPNCipher ?? AppConstants.OpenVPNCrypto.default.rawValue,
            usesSmallPackets: preferences.useSmallPackets
        )
    }
}

extension ProtocolSettings.VPNProtocol {
    fileprivate init(_ vpnType: KapePlatformSDKVPNType) {
        switch vpnType {
        case .wireGuard: self = .wireGuard
        case .openVPN: self = .openVPN
        default: self = .automatic
        }
    }

    fileprivate var vpnType: KapePlatformSDKVPNType {
        switch self {
        case .automatic: .automatic
        case .wireGuard: .wireGuard
        case .openVPN: .openVPN
        }
    }
}

extension ProtocolSettings.Transport {
    fileprivate init(_ socketType: AppConstants.OpenVPNSocketType?) {
        switch socketType {
        case .udp: self = .udp
        case .tcp: self = .tcp
        case nil: self = .automatic
        }
    }

    fileprivate var socketType: AppConstants.OpenVPNSocketType? {
        switch self {
        case .automatic: nil
        case .udp: .udp
        case .tcp: .tcp
        }
    }
}
