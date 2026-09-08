//
//  SettingsViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2020 Private Internet Access, Inc.
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

import PIALibrary
import PIALocalizations
import SafariServices
import UIKit
import WidgetKit

private let log = PIALogger.logger(for: SettingsViewController.self)

final class SettingsViewController: AutolayoutViewController, SettingsDelegate {
    static let rowHeight: CGFloat = 51

    private struct Cells {
        static let setting = "SettingCell"
        static let protocolCell = "ProtocolTableViewCell"
        static let footer = "FooterCell"
        static let header = "HeaderCell"
    }

    @IBOutlet private weak var tableView: UITableView!

    private var isResetting = false

    private var pendingPreferences: Client.Preferences.Editable!

    private var pendingVPNAction: VPNAction?

    var shouldSetWireGuardSettings = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = Self.rowHeight

        reloadSettings()

        if UserInterface.isIpad {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(viewHasRotated),
                name: UIDevice.orientationDidChangeNotification, object: nil)
        }

        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshSettings),
            name: .RefreshSettings,
            object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(reloadSettings),
            name: .ReloadSettings,
            object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshWireGuardSettings),
            name: .RefreshWireGuardSettings,
            object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(resetSettingsNavigationStack),
            name: .ResetSettingsNavigationStack,
            object: nil)

        if shouldSetWireGuardSettings {
            refreshWireGuardSettings()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Menu.Item.settings)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let base = segue.destination as? PIABaseSettingsViewController {
            base.settingsDelegate = self
            base.pendingPreferences = pendingPreferences
        }
    }

    func updateSocketType(socketType: String?) {
        pendingPreferences.openVPNSocketType = socketType
        updateRemotePort(port: ProtocolSettingsViewController.AUTOMATIC_PORT)
    }

    /// The tunnel derives its endpoints from the stored port and transport, so the port is all this
    /// has to record — the endpoint list the legacy OpenVPN builder needed is gone with it.
    func updateRemotePort(port: UInt16) {
        pendingPreferences.openVPNPort = Int(port)
        savePreferences()
    }

    func updateDataEncryption(encryption value: String) {
        pendingPreferences.openVPNCipher = value
        savePreferences()
    }

    func updateSetting(_ setting: SettingSection, withValue value: Any?) {

        if let protocolSection = setting as? ProtocolsSections, protocolSection == .protocolSelection {
            resetProtocolSettings()
            return
        }

        if let networkSection = setting as? NetworkSections {
            switch networkSection {
            case .dns:
                if let settingValue = value as? String {
                    let dnsServers = DNSList.shared.valueForKey(settingValue)
                    // Automatic can end up running either protocol, so its choice has to reach both
                    // slots — previously it only ever wrote the WireGuard one, and a fallback to
                    // OpenVPN silently ignored the user's resolvers.
                    switch KapePlatformSDKVPNType(rawValue: pendingPreferences.vpnType) {
                    case .openVPN:
                        pendingPreferences.openVPNDnsServers = dnsServers
                    case .wireGuard:
                        pendingPreferences.wireGuardDnsServers = dnsServers
                    default:
                        pendingPreferences.openVPNDnsServers = dnsServers
                        pendingPreferences.wireGuardDnsServers = dnsServers
                    }
                }
            }
        }

        savePreferences()

    }

    // MARK: Protocol settings

    private func validateRemotePort() {
        let port = UInt16(exactly: pendingPreferences.openVPNPort) ?? 0
        guard port != ProtocolSettingsViewController.AUTOMATIC_PORT else {
            return
        }

        let socketType = AppConstants.OpenVPNSocketType(rawValue: pendingPreferences.openVPNSocketType ?? "")
        if let socketType {
            let ovpnPorts = Client.providers.serverProvider.currentServersConfiguration.ovpnPorts
            let servedPorts = (socketType == .udp) ? ovpnPorts.udp : ovpnPorts.tcp
            guard !servedPorts.isEmpty, !servedPorts.contains(port) else {
                return
            }
        }

        log.debug("Remote port \(port) is not served over \(socketType?.rawValue ?? "automatic") — resetting it to automatic")
        updateRemotePort(port: ProtocolSettingsViewController.AUTOMATIC_PORT)
    }

    private func resetProtocolSettings() {
        pendingPreferences.openVPNSocketType = nil
        pendingPreferences.openVPNCipher = AppConstants.OpenVPNCrypto.default.rawValue
        pendingPreferences.openVPNAuth = AppConstants.OpenVPNCrypto.defaultAuth

        updateRemotePort(port: ProtocolSettingsViewController.AUTOMATIC_PORT)
    }

    // MARK: Actions

    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(L10n.Menu.Item.settings)
    }

    @objc func refreshSettings() {
        tableView.reloadData()
    }

    @objc func resetSettingsNavigationStack() {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @objc private func refreshWireGuardSettings() {
        pendingPreferences.vpnType = KapePlatformSDKVPNType.wireGuard.rawValue
        savePreferences()
    }

    func resetToDefaultSettings() {
        let alert = Macros.alert(
            L10n.Settings.Reset.Defaults.Confirm.title,
            L10n.Settings.Reset.Defaults.Confirm.message
        )
        alert.addDestructiveActionWithTitle(L10n.Settings.Reset.Defaults.Confirm.button) {
            self.doReset()
        }
        alert.addCancelAction(L10n.Global.cancel)
        self.present(alert, animated: true, completion: nil)
    }

    private func doReset() {

        isResetting = true

        // only don't reset selected server
        let savedServer = pendingPreferences.preferredServer
        pendingPreferences.reset()
        pendingPreferences.preferredServer = savedServer

        // reset NMT preferences
        let preferences = Client.preferences.editable()

        var genericRules = [String: Int]()
        genericRules[NMTType.protectedWiFi.rawValue] = NMTRules.alwaysConnect.rawValue
        genericRules[NMTType.openWiFi.rawValue] = NMTRules.alwaysConnect.rawValue
        genericRules[NMTType.cellular.rawValue] = NMTRules.alwaysConnect.rawValue

        preferences.nmtTrustedNetworkRules = pendingPreferences.nmtTrustedNetworkRules
        preferences.availableNetworks = pendingPreferences.availableNetworks
        preferences.nmtGenericRules = genericRules

        preferences.commit()

        AppPreferences.shared.reset()
        DNSList.shared.resetPlist()

        refreshSettings()
        reportUpdatedPreferences()

        Macros.postNotification(.PIASettingsHaveChanged)

    }

    func commitChanges(_ completionHandler: @escaping () -> Void) {
        let isResettingToDefaults = isResetting
        isResetting = false

        pendingVPNAction = pendingPreferences.requiredVPNAction()

        if isResettingToDefaults && pendingVPNAction == nil {
            pendingVPNAction = pendingPreferences.defaultVPNAction()
        }

        guard let action = pendingVPNAction else {
            commitNMTPreferences()
            commitAppPreferences()
            pendingPreferences.commit()
            super.dismissModal()
            return
        }

        let isDisconnected = (Client.providers.vpnProvider.vpnStatus == .disconnected)
        let completionHandlerAfterVPNAction: (Bool) -> Void = { (shouldReconnect) in
            self.showLoadingAnimation()
            action.execute { (error) in
                self.pendingVPNAction = nil

                if shouldReconnect && !isDisconnected {
                    Client.providers.vpnProvider.reconnect(after: nil, forceDisconnect: true) { (error) in
                        completionHandler()
                        self.hideLoadingAnimation()
                    }
                } else {
                    Client.providers.vpnProvider.updatePreferences(nil)
                    completionHandler()
                    self.hideLoadingAnimation()
                }
            }
        }

        // disconnected, commit and execute
        guard !isDisconnected else {
            commitPreferences()
            completionHandlerAfterVPNAction(false)
            return
        }

        if isResettingToDefaults {
            commitPreferences()

            let alert = Macros.alert(
                title,
                L10n.Settings.Commit.Messages.shouldReconnect
            )

            // reconnect -> reconnect VPN and close
            alert.addActionWithTitle(L10n.Settings.Commit.Buttons.reconnect) {
                completionHandlerAfterVPNAction(true)
            }

            // later -> close
            alert.addCancelActionWithTitle(L10n.Settings.Commit.Buttons.later) {
                completionHandler()
            }

            present(alert, animated: true, completion: nil)
            return
        }

        // must reconnect
        guard action.canRetainConnection else {
            let alert = Macros.alert(
                title,
                L10n.Settings.Commit.Messages.mustDisconnect
            )

            // reconnect -> reconnect VPN and close
            alert.addActionWithTitle(L10n.Settings.Commit.Buttons.reconnect) {
                self.commitPreferences()
                completionHandlerAfterVPNAction(true)
            }

            // cancel -> revert changes and close
            alert.addCancelActionWithTitle(L10n.Global.cancel) {
                completionHandler()
            }
            present(alert, animated: true, completion: nil)
            return
        }

        // should reconnect
        guard !pendingPreferences.suggestsVPNReconnection() else {
            commitPreferences()

            let alert = Macros.alert(
                title,
                L10n.Settings.Commit.Messages.shouldReconnect
            )

            // reconnect -> reconnect VPN and close
            alert.addActionWithTitle(L10n.Settings.Commit.Buttons.reconnect) {
                completionHandlerAfterVPNAction(true)
            }

            // later -> close
            alert.addCancelActionWithTitle(L10n.Settings.Commit.Buttons.later) {
                completionHandler()
            }

            present(alert, animated: true, completion: nil)
            return
        }

        // action doesn't affect VPN connection, commit and execute
        commitPreferences()
        completionHandlerAfterVPNAction(false)
    }

    private func commitAppPreferences() {
        // The OpenVPN options used to be mirrored into `AppPreferences` here. They are staged in
        // `pendingPreferences` now, and `AppPreferences` writes the *same* app-group keys, so
        // `pendingPreferences.commit()` below is the single write.
        AppPreferences.shared.todayWidgetVpnProtocol = Client.preferences.vpnType.vpnProtocol
        AppPreferences.shared.todayWidgetVpnSocket = Client.preferences.vpnType.port
        AppPreferences.shared.todayWidgetVpnPort = Client.preferences.vpnType.socket

        WidgetCenter.shared.reloadTimelines(ofKind: "PIAWidget")
    }

    private func commitPreferences() {
        commitNMTPreferences()
        commitAppPreferences()
        pendingPreferences.commit()
    }

    private func commitNMTPreferences() {
        //Update with values from Trusted Network Settings
        pendingPreferences.nmtTrustedNetworkRules = Client.preferences.nmtTrustedNetworkRules
        pendingPreferences.nmtRulesEnabled = Client.preferences.nmtRulesEnabled
        pendingPreferences.availableNetworks = Client.preferences.availableNetworks
        pendingPreferences.nmtGenericRules = Client.preferences.nmtGenericRules
    }

    // MARK: Unwind segues

    @IBAction private func unwoundContentBlockerViewController(_ segue: UIStoryboardSegue) {
    }

    // MARK: Helpers

    @objc func reloadSettings() {
        pendingPreferences = Client.preferences.editable()

        validateRemotePort()
        validateDNSList()
        tableView.reloadData()
    }

    func reportUpdatedPreferences() {
        pendingVPNAction = pendingPreferences.requiredVPNAction()
    }

    /// MTU no longer belongs here: the tunnel derives it from `useSmallPackets`, which is already a
    /// staged preference.
    func savePreferences() {
        updateCustomDNSAppPreferences()
        refreshSettings()
        reportUpdatedPreferences()
    }

    private func updateCustomDNSAppPreferences() {
        let dnsServers =
            KapePlatformSDKVPNType(rawValue: pendingPreferences.vpnType) == .wireGuard
            ? pendingPreferences.wireGuardDnsServers
            : pendingPreferences.openVPNDnsServers

        AppPreferences.shared.usesCustomDNS = DNSList.shared.hasCustomDNS(for: pendingPreferences.vpnType, in: dnsServers)
    }

    // MARK: ModalController

    override func dismissModal() {
        commitChanges {
            Macros.postNotification(.PIASettingsHaveChanged)
            super.dismissModal()
        }
    }

    // MARK: Restylable

    override func viewShouldRestyle() {
        super.viewShouldRestyle()

        styleNavigationBarWithTitle(L10n.Menu.Item.settings)
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        Theme.current.applyPrincipalBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
        tableView.reloadData()

    }

    ///Check if the current value of the DNS is valid. If not, reset to default PIA server
    private func validateDNSList() {
        guard Flags.shared.enablesDNSSettings else {
            return
        }

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

}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sections = SettingOptions.allCases
        if !Flags.shared.enablesDevelopmentSettings {
            sections.removeAll(where: { $0 == SettingOptions.development })
        }
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.setting, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil
        cell.selectionStyle = .default

        guard let section = SettingOptions(rawValue: indexPath.row) else {
            log.debug("unknown section raw value \(indexPath.row)")
            return cell
        }

        cell.textLabel?.text = section.localizedTitleMessage()
        cell.detailTextLabel?.text = ""
        cell.imageView?.image = section.imageForSection().aspectScaled(toFit: CGSize(width: 25, height: 25))

        switch section {
        case .automation:
            cell.detailTextLabel?.text = Client.preferences.nmtRulesEnabled ? L10n.Global.enabled : L10n.Global.disabled
        case .protocols:
            cell.detailTextLabel?.text = pendingPreferences?.vpnType.vpnProtocol
        default: break
        }

        Theme.current.applySecondaryBackground(cell)
        if let textLabel = cell.textLabel {
            Theme.current.applySettingsCellTitle(
                textLabel,
                appearance: .dark)
            textLabel.backgroundColor = .clear
        }
        if let detailLabel = cell.detailTextLabel {
            Theme.current.applySubtitle(detailLabel)
            detailLabel.backgroundColor = .clear
        }

        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingOptions(rawValue: indexPath.row) else {
            log.debug("unknown section raw value \(indexPath.row)")
            return
        }

        switch section {
        case .protocols:
            self.perform(segue: StoryboardSegue.Main.protocolSettingsSegue, sender: nil)
        case .network:
            self.perform(segue: StoryboardSegue.Main.networkSettingsSegue, sender: nil)
        case .privacyFeatures:
            self.perform(segue: StoryboardSegue.Main.privacyFeaturesSettingsSegue, sender: nil)
        case .automation:
            self.perform(segue: StoryboardSegue.Main.automationSettingsSegue, sender: nil)
        case .help:
            self.perform(segue: StoryboardSegue.Main.helpSettingsSegue, sender: nil)
        case .development:
            self.perform(segue: StoryboardSegue.Main.developmentSettingsSegue, sender: nil)
        default:
            self.perform(segue: StoryboardSegue.Main.generalSettingsSegue, sender: nil)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionFooter(view)
    }

}
