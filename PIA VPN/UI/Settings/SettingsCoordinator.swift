//
//  SettingsCoordinator.swift
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
import PIALocalizations
import PIASettings
import UIKit
import WidgetKit

private let log = PIALogger.logger(for: SettingsCoordinator.self)

/// Stages preference edits from every settings screen and commits them when the modal closes.
@MainActor
final class SettingsCoordinator: @MainActor FlowCoordinator, SettingsDelegate {
    private weak var presenter: UIViewController?
    private weak var host: SettingsHostingController?
    private let activatesWireGuard: Bool
    private let subject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var pendingPreferences: Client.Preferences.Editable!
    private var isResetting = false

    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(presenter: UIViewController, activatesWireGuard: Bool = false) {
        self.presenter = presenter
        self.activatesWireGuard = activatesWireGuard
    }

    func start() {
        guard let presenter else {
            subject.send(completion: .finished)
            return
        }

        reloadPreferences()
        if activatesWireGuard {
            activateWireGuard()
        }
        observeNotifications()

        let host = SettingsHostingController(
            rootView: makeRootView(),
            onDismiss: { [subject] in subject.send(completion: .finished) }
        )
        host.onWillAppear = { [weak self] in self?.refreshRootView() }
        host.onClose = { [weak self] dismiss in
            guard let self else { return dismiss() }
            commitChanges(dismiss: dismiss) {
                Macros.postNotification(.PIASettingsHaveChanged)
                dismiss()
            }
        }
        self.host = host
        ModalNavigationSegue.configureAndPresent(modal: host, from: presenter)
    }

    // MARK: Navigation

    private func makeRootView() -> MainSettingsView {
        let values: [MainSettingsView.Destination: String] = [
            .protocols: pendingPreferences.vpnType.vpnProtocol,
            .automation: Client.preferences.nmtRulesEnabled ? L10n.Global.enabled : L10n.Global.disabled
        ]
        return MainSettingsView(values: values) { [weak self] in self?.show($0) }
    }

    private func refreshRootView() {
        host?.rootView = makeRootView()
    }

    private func show(_ destination: MainSettingsView.Destination) {
        guard let parent = host?.navigationController else { return }
        switch destination {
        case .general:
            run(GeneralSettingsCoordinator(parent: parent) { [weak self] in self?.resetToDefaultSettings() })
        case .protocols:
            run(ProtocolSettingsCoordinator(parent: parent, pendingPreferences: pendingPreferences, settingsDelegate: self))
        case .network:
            run(NetworkSettingsCoordinator(parent: parent, pendingPreferences: pendingPreferences, settingsDelegate: self))
        case .privacyFeatures:
            run(PrivacyFeaturesSettingsCoordinator(parent: parent, pendingPreferences: pendingPreferences))
        case .automation:
            run(AutomationSettingsCoordinator(parent: parent, pendingPreferences: pendingPreferences))
        case .help:
            run(HelpSettingsCoordinator(parent: parent, pendingPreferences: pendingPreferences))
        }
    }

    private func run<C: FlowCoordinator>(_ coordinator: C) where C.Output == Void {
        Task { await coordinator.startAsync() }
    }

    private func observeNotifications() {
        let center = NotificationCenter.default
        center.publisher(for: .ReloadSettings)
            .sink { [weak self] _ in self?.reloadPreferences() }
            .store(in: &cancellables)
        center.publisher(for: .RefreshWireGuardSettings)
            .sink { [weak self] _ in self?.activateWireGuard() }
            .store(in: &cancellables)
        center.publisher(for: .ResetSettingsNavigationStack)
            .sink { [weak self] _ in self?.host?.navigationController?.popToRootViewController(animated: true) }
            .store(in: &cancellables)
    }

    // MARK: SettingsDelegate

    func savePreferences() {
        updateCustomDNSAppPreferences()
        refreshRootView()
    }

    func resetProtocolSettings() {
        pendingPreferences.openVPNSocketType = nil
        pendingPreferences.openVPNCipher = AppConstants.OpenVPNCrypto.default.rawValue
        pendingPreferences.openVPNAuth = AppConstants.OpenVPNCrypto.defaultAuth
        updateRemotePort(port: ProtocolSettings.automaticPort)
    }

    func updateSocketType(socketType: String?) {
        pendingPreferences.openVPNSocketType = AppConstants.OpenVPNSocketType(rawValue: socketType ?? "")?.rawValue
        updateRemotePort(port: ProtocolSettings.automaticPort)
    }

    /// The tunnel derives its endpoints from the stored port and transport, so the port is all this has to record.
    func updateRemotePort(port: UInt16) {
        pendingPreferences.openVPNPort = Int(port)
        savePreferences()
    }

    func updateDataEncryption(encryption value: String) {
        pendingPreferences.openVPNCipher = value
        savePreferences()
    }

    func updateDNS(key: String) {
        let dnsServers = DNSList.shared.valueForKey(key)
        // Automatic can run either protocol, so its choice has to reach both slots.
        switch KapePlatformSDKVPNType(rawValue: pendingPreferences.vpnType) {
        case .openVPN:
            pendingPreferences.openVPNDnsServers = dnsServers
        case .wireGuard:
            pendingPreferences.wireGuardDnsServers = dnsServers
        default:
            pendingPreferences.openVPNDnsServers = dnsServers
            pendingPreferences.wireGuardDnsServers = dnsServers
        }
        savePreferences()
    }

    // MARK: Preferences

    private func reloadPreferences() {
        pendingPreferences = Client.preferences.editable()
        validateRemotePort()
        validateDNSList()
        refreshRootView()
    }

    private func activateWireGuard() {
        pendingPreferences.vpnType = KapePlatformSDKVPNType.wireGuard.rawValue
        savePreferences()
    }

    private func validateRemotePort() {
        let port = UInt16(exactly: pendingPreferences.openVPNPort) ?? 0
        guard port != ProtocolSettings.automaticPort else { return }

        let socketType = AppConstants.OpenVPNSocketType(rawValue: pendingPreferences.openVPNSocketType ?? "")
        if let socketType {
            let ovpnPorts = Client.providers.serverProvider.currentServersConfiguration.ovpnPorts
            let servedPorts = (socketType == .udp) ? ovpnPorts.udp : ovpnPorts.tcp
            guard !servedPorts.isEmpty, !servedPorts.contains(port) else { return }
        }

        log.debug("Remote port \(port) is not served over \(socketType?.rawValue ?? "automatic") — resetting it to automatic")
        updateRemotePort(port: ProtocolSettings.automaticPort)
    }

    /// Resets DNS servers no longer in the list to the PIA default.
    private func validateDNSList() {
        guard Flags.shared.enablesDNSSettings else { return }

        let isKnown: ([String]) -> Bool = { servers in
            DNSList.shared.dnsList.contains { dns in
                dns.contains { $0.value == servers }
            }
        }
        if !isKnown(pendingPreferences.wireGuardDnsServers) {
            pendingPreferences.wireGuardDnsServers = []
        }
        if !isKnown(pendingPreferences.openVPNDnsServers) {
            pendingPreferences.openVPNDnsServers = []
        }
    }

    private func updateCustomDNSAppPreferences() {
        let dnsServers =
            KapePlatformSDKVPNType(rawValue: pendingPreferences.vpnType) == .wireGuard
            ? pendingPreferences.wireGuardDnsServers
            : pendingPreferences.openVPNDnsServers
        AppPreferences.shared.usesCustomDNS = DNSList.shared.hasCustomDNS(for: pendingPreferences.vpnType, in: dnsServers)
    }

    private func resetToDefaultSettings() {
        isResetting = true

        let savedServer = pendingPreferences.preferredServer
        pendingPreferences.reset()
        pendingPreferences.preferredServer = savedServer

        let preferences = Client.preferences.editable()
        preferences.nmtTrustedNetworkRules = pendingPreferences.nmtTrustedNetworkRules
        preferences.availableNetworks = pendingPreferences.availableNetworks
        preferences.nmtGenericRules = [
            NMTType.protectedWiFi.rawValue: NMTRules.alwaysConnect.rawValue,
            NMTType.openWiFi.rawValue: NMTRules.alwaysConnect.rawValue,
            NMTType.cellular.rawValue: NMTRules.alwaysConnect.rawValue
        ]
        preferences.commit()

        AppPreferences.shared.reset()
        DNSList.shared.resetPlist()

        Macros.postNotification(.PIASettingsHaveChanged)
    }

    // MARK: Commit

    /// `dismiss` closes silently when nothing affects the VPN; `completion` runs after any VPN action or alert.
    private func commitChanges(dismiss: @escaping () -> Void, completion: @escaping () -> Void) {
        let isResettingToDefaults = isResetting
        isResetting = false

        var pendingAction = pendingPreferences.requiredVPNAction()
        if isResettingToDefaults && pendingAction == nil {
            pendingAction = pendingPreferences.defaultVPNAction()
        }

        guard let action = pendingAction else {
            commitPreferences()
            dismiss()
            return
        }

        let isDisconnected = Client.providers.vpnProvider.vpnStatus == .disconnected
        let execute: (Bool) -> Void = { [weak self] shouldReconnect in
            let loading = self?.presenter as? AnimatingLoadingDelegate
            loading?.showLoadingAnimation()
            action.execute { _ in
                if shouldReconnect && !isDisconnected {
                    Client.providers.vpnProvider.reconnect(after: nil, forceDisconnect: true) { _ in
                        completion()
                        loading?.hideLoadingAnimation()
                    }
                } else {
                    Client.providers.vpnProvider.updatePreferences(nil)
                    completion()
                    loading?.hideLoadingAnimation()
                }
            }
        }

        if isDisconnected {
            commitPreferences()
            execute(false)
        } else if isResettingToDefaults || (action.canRetainConnection && pendingPreferences.suggestsVPNReconnection()) {
            commitPreferences()
            presentAlert(L10n.Settings.Commit.Messages.shouldReconnect, cancelTitle: L10n.Settings.Commit.Buttons.later) {
                execute(true)
            } onCancel: {
                completion()
            }
        } else if !action.canRetainConnection {
            presentAlert(L10n.Settings.Commit.Messages.mustDisconnect, cancelTitle: L10n.Global.cancel) { [weak self] in
                self?.commitPreferences()
                execute(true)
            } onCancel: {
                completion()
            }
        } else {
            commitPreferences()
            execute(false)
        }
    }

    private func presentAlert(
        _ message: String,
        cancelTitle: String,
        onReconnect: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        let alert = Macros.alert(L10n.Menu.Item.settings, message)
        alert.addActionWithTitle(L10n.Settings.Commit.Buttons.reconnect, handler: onReconnect)
        alert.addCancelActionWithTitle(cancelTitle, handler: onCancel)
        host?.present(alert, animated: true)
    }

    private func commitPreferences() {
        pendingPreferences.nmtTrustedNetworkRules = Client.preferences.nmtTrustedNetworkRules
        pendingPreferences.nmtRulesEnabled = Client.preferences.nmtRulesEnabled
        pendingPreferences.availableNetworks = Client.preferences.availableNetworks
        pendingPreferences.nmtGenericRules = Client.preferences.nmtGenericRules

        WidgetConnectionDetails.current.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "PIAWidget")

        pendingPreferences.commit()
    }
}

/// Runs the commit flow before the modal closes, and reports completion however it goes away.
final class SettingsHostingController: AutolayoutHostingController<MainSettingsView> {
    var onClose: ((@escaping () -> Void) -> Void)?
    var onWillAppear: (() -> Void)?

    deinit {
        onDismiss()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onWillAppear?()
    }

    override func dismissModal(completion: (() -> Void)? = nil) {
        guard let onClose else {
            return super.dismissModal(completion: completion)
        }
        onClose { super.dismissModal(completion: completion) }
    }
}
