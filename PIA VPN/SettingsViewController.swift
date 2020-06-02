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

import UIKit
import PIALibrary
import TunnelKit
import SafariServices
import SwiftyBeaver
import PIAWireguard

private let log = SwiftyBeaver.self

private extension String {
    var vpnTypeDescription: String {
        switch self {
        case PIAWGTunnelProfile.vpnType:
            return "WireGuard®"
        case PIATunnelProfile.vpnType:
            return "OpenVPN"
        case IKEv2Profile.vpnType:
            return "IPSec (IKEv2)"
        default:
            return self
        }
    }
}

enum Setting: Int {
    case vpnProtocolSelection
    
    case vpnSocket
    
    case vpnPort
    
    case vpnDns
    
    case encryptionCipher
    
    case encryptionDigest
    
    case encryptionHandshake
        
    case useSmallPackets

    case ikeV2EncryptionAlgorithm
    
    case ikeV2IntegrityAlgorithm
    
    case automaticReconnection

    case trustedNetworks

    case connectShortcut

    case disconnectShortcut
    
    case serversNetwork

    case geoServers

    case contentBlockerState
    
    case contentBlockerRefreshRules
    
    case mace
    
    case darkTheme
    
    case sendDebugLog
    
    case resetSettings
    
    // development
    
    //        case truncateDebugLog
    //
    //        case recalculatePingTimes
    //
    //        case invokeMACERequest
    
    case customServers
    
    case publicUsername
    
    case username
    
    case password
    
    case resolveGoogleAdsDomain
}

protocol SettingsViewControllerDelegate: class {
    
    /**
     Called to update the setting sent as parameter.
     
     - Parameter setting: The setting to update.
     - Parameter value: Optional value to update the setting
     */
    func updateSetting(_ setting: Setting, withValue value: Any?)
}


class SettingsViewController: AutolayoutViewController {

    fileprivate static let DNS: String = "DNS"

    fileprivate static let AUTOMATIC_SOCKET = "automatic"

    fileprivate static let AUTOMATIC_PORT: UInt16 = 0

    private enum Section: Int {
        
        case connection

        case encryption
        
        case smallPackets

        case ikeV2encryption
        
        case applicationSettings
                
        case autoConnectSettings

        case geoSettings

        case contentBlocker

        case applicationInformation
        
        case reset

        case development
        
        case preview
    }

    private static let allSections: [Section] = [
        .connection,
        .encryption,
        .smallPackets,
        .ikeV2encryption,
        .applicationSettings,
        .autoConnectSettings,
        .geoSettings,
        .applicationInformation,
        .reset,
        .contentBlocker,
        .preview
    ]

    private var visibleSections: [Section] = []

    private var rowsBySection: [Section: [Setting]] = [
        .connection: [
            .vpnProtocolSelection,
            .vpnSocket,
            .vpnPort,
            .vpnDns
        ],
        .encryption: [
            .encryptionCipher,
            .encryptionDigest,
            .encryptionHandshake,
        ],
        .ikeV2encryption: [
            .ikeV2EncryptionAlgorithm,
            .ikeV2IntegrityAlgorithm,
        ],
        .smallPackets: [
        ], // dynamic
        .applicationSettings: [], // dynamic
        .autoConnectSettings: [
            .trustedNetworks
        ],
        .geoSettings: [
            .geoServers
        ],
        .contentBlocker: [
            .contentBlockerState,
            .contentBlockerRefreshRules
        ],
        .applicationInformation: [
            .sendDebugLog
        ],
        .reset: [
            .resetSettings
        ],
        .preview: [
            .serversNetwork,
        ],
        .development: [
//            .truncateDebugLog,
//            .recalculatePingTimes,
//            .invokeMACERequest,
//            .mace,
            .customServers,
            .publicUsername,
            .username,
            .password,
            .resolveGoogleAdsDomain
        ]
    ]
    
    private struct Cells {
        static let setting = "SettingCell"
        static let protocolCell = "ProtocolTableViewCell"
        static let footer = "FooterCell"
        static let header = "HeaderCell"
    }
    
    @IBOutlet private weak var tableView: UITableView!

    private lazy var switchAutoJoinWiFi = UISwitch()

    private lazy var switchPersistent = UISwitch()

    private lazy var switchMACE = UISwitch()
    
    private lazy var switchContentBlocker = UISwitch()
    
    private lazy var switchDarkMode = UISwitch()
        
    private lazy var switchSmallPackets = UISwitch()

    private lazy var switchServersNetwork = UISwitch()

    private lazy var switchGeoServers = UISwitch()

    private lazy var imvSelectedOption = UIImageView(image: Asset.accessorySelected.image)

    private var isContentBlockerEnabled = false

    private var pendingPreferences: Client.Preferences.Editable!
    
    private var pendingOpenVPNSocketType: SocketType?
    
    private var pendingHandshake: OpenVPN.Configuration.Handshake!

    private var pendingOpenVPNConfiguration: OpenVPN.ConfigurationBuilder!

    private var pendingWireguardVPNConfiguration: PIAWireguardConfiguration!

    private var pendingVPNAction: VPNAction?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        buttonConfirm.isEnabled = false
//        navigationItem.rightBarButtonItem = buttonConfirm
        
        pendingPreferences = Client.preferences.editable()

        // XXX: fall back to default configuration (don't rely on client library)
        
        guard let currentOpenVPNConfiguration = pendingPreferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNTunnelProvider.Configuration ??
            Client.preferences.defaults.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNTunnelProvider.Configuration else {
            fatalError("No default VPN custom configuration provided for PIA OpenVPN protocol")
        }
        
        guard let currentWireguardVPNConfiguration = pendingPreferences.vpnCustomConfiguration(for: PIAWGTunnelProfile.vpnType) as? PIAWireguardConfiguration ??
            Client.preferences.defaults.vpnCustomConfiguration(for: PIAWGTunnelProfile.vpnType) as? PIAWireguardConfiguration else {
            fatalError("No default VPN custom configuration provided for PIA Wireguard protocol")
        }
        
        pendingOpenVPNSocketType = AppPreferences.shared.piaSocketType
        pendingHandshake = AppPreferences.shared.piaHandshake
        pendingOpenVPNConfiguration = currentOpenVPNConfiguration.sessionConfiguration.builder()
        pendingWireguardVPNConfiguration = currentWireguardVPNConfiguration

        validateDNSList()

        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1.0
        tableView.estimatedSectionHeaderHeight = 1.0
        
        switchPersistent.addTarget(self, action: #selector(togglePersistentConnection(_:)), for: .valueChanged)
        switchMACE.addTarget(self, action: #selector(toggleMACE(_:)), for: .valueChanged)
        switchContentBlocker.addTarget(self, action: #selector(showContentBlockerTutorial), for: .touchUpInside)
        switchDarkMode.addTarget(self, action: #selector(toggleDarkMode(_:)), for: .valueChanged)
        switchSmallPackets.addTarget(self, action: #selector(toggleSmallPackets(_:)), for: .valueChanged)
        switchServersNetwork.addTarget(self, action: #selector(toggleServerNetwork(_:)), for: .valueChanged)
        switchGeoServers.addTarget(self, action: #selector(toggleGEOServers(_:)), for: .valueChanged)
        redisplaySettings()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshContentBlockerState), name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPersistentConnectionValue),
                                               name: .PIAPersistentConnectionSettingHaveChanged,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewHasRotated),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSettings),
                                               name: .RefreshSettings,
                                               object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshContentBlockerState()
        styleNavigationBarWithTitle(L10n.Menu.Item.settings)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let customDNSSettingsVC = segue.destination as? CustomDNSSettingsViewController {
            customDNSSettingsVC.delegate = self
            customDNSSettingsVC.vpnType = pendingPreferences.vpnType == PIATunnelProfile.vpnType ? PIATunnelProfile.vpnType : PIAWGTunnelProfile.vpnType
            let ips = DNSList.shared.valueForKey(pendingPreferences.vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY)
            if ips.count > 0 {
                customDNSSettingsVC.primaryDNSValue = ips.first
                if ips.count > 1 {
                    customDNSSettingsVC.secondaryDNSValue = ips.last
                }
            }
        } else if let trustedNetworksVC = segue.destination as? TrustedNetworksViewController {
            trustedNetworksVC.persistentConnectionValue = pendingPreferences.isPersistentConnection
            trustedNetworksVC.vpnType = pendingPreferences.vpnType
        }
    }
    
    // MARK: Actions
    @objc private func edit(_ sender: Any?) {
        self.perform(segue: StoryboardSegue.Main.customDNSSegueIdentifier)
    }

    @objc private func togglePersistentConnection(_ sender: UISwitch) {
        if !sender.isOn,
            Client.preferences.nmtRulesEnabled {
                let alert = Macros.alert(nil, L10n.Settings.Nmt.Killswitch.disabled)
                alert.addCancelAction(L10n.Global.close)
                alert.addActionWithTitle(L10n.Global.enable) { [weak self] in
                    self?.pendingPreferences.isPersistentConnection = true
                    self?.redisplaySettings()
                    self?.reportUpdatedPreferences()
                }
                present(alert, animated: true, completion: nil)
        }
        
        pendingPreferences.isPersistentConnection = sender.isOn
        redisplaySettings()
        reportUpdatedPreferences()

    }
     
    @objc private func toggleMACE(_ sender: UISwitch) {
        pendingPreferences.mace = sender.isOn
        redisplaySettings()
        reportUpdatedPreferences()
    }
    
    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(L10n.Menu.Item.settings)
    }

    // XXX: no need to bufferize app preferences
    @objc private func toggleDarkMode(_ sender: UISwitch) {
        AppPreferences.shared.transitionTheme(to: sender.isOn ? .dark : .light)
    }

    @objc private func toggleSmallPackets(_ sender: UISwitch) {
        AppPreferences.shared.useSmallPackets = sender.isOn
        savePreferences()
    }
    
    @objc private func toggleServerNetwork(_ sender: UISwitch) {
        
        guard Client.providers.vpnProvider.vpnStatus == .disconnected else {
            sender.setOn(!sender.isOn, animated: true)
            let message = L10n.Settings.Server.Network.alert
            let alert = Macros.alert(nil, message)
            alert.addDefaultAction(L10n.Global.ok)
            self.present(alert, animated: true, completion: nil)
            return
        }

        self.showLoadingAnimation()
        let currentValue = Client.configuration.currentServerNetwork()
        Client.configuration.setServerNetworks(to: sender.isOn ? .gen4 : .legacy)
        Client.resetServers(completionBlock: { error in
            self.hideLoadingAnimation()
            if error == nil {
                NotificationCenter.default.post(name: .PIAServerHasBeenUpdated,
                object: self,
                userInfo: nil)
            } else {
                Client.configuration.setServerNetworks(to: currentValue)
                self.tableView.reloadData()
            }
        })
        
    }
    
    @objc private func toggleGEOServers(_ sender: UISwitch) {
        AppPreferences.shared.showGeoServers = sender.isOn
    }

    @objc private func showContentBlockerTutorial() {
        perform(segue: StoryboardSegue.Main.contentBlockerSegueIdentifier)
    }

    @objc private func refreshContentBlockerState(withHUD: Bool = false) {
        if #available(iOS 10, *) {
            if withHUD {
                self.showLoadingAnimation()
            }
            SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: AppConstants.Extensions.adBlockerBundleIdentifier) { (state, error) in
                DispatchQueue.main.async {
                    self.hideLoadingAnimation()
                    
                    self.isContentBlockerEnabled = state?.isEnabled ?? false
                    self.redisplaySettings()
                }
            }
        }
    }
    
    @objc private func refreshPersistentConnectionValue() {
        pendingPreferences.isPersistentConnection = Client.preferences.isPersistentConnection
        tableView.reloadData()
    }
    
    @objc private func refreshSettings() {
        tableView.reloadData()
    }
    
    private func refreshContentBlockerRules() {
        self.showLoadingAnimation()
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: AppConstants.Extensions.adBlockerBundleIdentifier) { (error) in
            if let error = error {
                log.error("Could not reload Safari Content Blocker: \(error)")
            }
            DispatchQueue.main.async {
                self.hideLoadingAnimation()
            }
        }
    }
    
    private func submitTunnelLog() {
        
        if Client.providers.vpnProvider.isVPNConnected {
            
            self.showLoadingAnimation()

            Client.providers.vpnProvider.submitLog { (log, error) in
                self.hideLoadingAnimation()
                
                let title: String
                let message: String
            
                defer {
                    let alert = Macros.alert(title, message)
                    alert.addDefaultAction(L10n.Global.ok)
                    self.present(alert, animated: true, completion: nil)
                }
                
                guard let log = log else {
                    title = L10n.Settings.ApplicationInformation.Debug.Failure.title
                    message = L10n.Settings.ApplicationInformation.Debug.Failure.message
                    return
                }
                guard !log.isEmpty else {
                    title = L10n.Settings.ApplicationInformation.Debug.Empty.title
                    message = L10n.Settings.ApplicationInformation.Debug.Empty.message
                    return
                }

                title = L10n.Settings.ApplicationInformation.Debug.Success.title
                message = L10n.Settings.ApplicationInformation.Debug.Success.message(log.identifier)
            }

        } else {
            
            let alert = Macros.alert(
                nil,
                L10n.Settings.Log.Connected.error
            )
            alert.addCancelAction(L10n.Global.close)
            self.present(alert, animated: true, completion: nil)

        }
        
    }
    
    private func resetToDefaultSettings() {
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

        // only don't reset selected server
        let savedServer = pendingPreferences.preferredServer
        pendingPreferences.reset()
        pendingPreferences.preferredServer = savedServer
        
        // reset NMT preferences
        let preferences = Client.preferences.editable()
        preferences.trustedNetworks = pendingPreferences.trustedNetworks
        preferences.availableNetworks = pendingPreferences.availableNetworks
        preferences.shouldConnectForAllNetworks = pendingPreferences.shouldConnectForAllNetworks
        preferences.useWiFiProtection = pendingPreferences.useWiFiProtection
        preferences.trustCellularData = pendingPreferences.trustCellularData
        preferences.ikeV2IntegrityAlgorithm = pendingPreferences.ikeV2IntegrityAlgorithm
        preferences.ikeV2EncryptionAlgorithm = pendingPreferences.ikeV2EncryptionAlgorithm
        preferences.commit()

        guard let currentOpenVPNConfiguration = pendingPreferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNTunnelProvider.Configuration else {
            fatalError("No default VPN custom configuration provided for PIA protocol")
        }
        AppPreferences.shared.reset()
        DNSList.shared.resetPlist()
        pendingOpenVPNSocketType = AppPreferences.shared.piaSocketType
        pendingHandshake = AppPreferences.shared.piaHandshake
        pendingOpenVPNConfiguration = currentOpenVPNConfiguration.sessionConfiguration.builder()
        pendingWireguardVPNConfiguration = PIAWireguardConfiguration(customDNSServers: [])

        redisplaySettings()
        reportUpdatedPreferences()
    }
    
//    @IBAction private func confirmChangesImmediately(_ sender: Any?) {
//        confirmChanges(retainingConnection: false) {
//            self.buttonConfirm.isEnabled = false
//        }
//    }
    
    func commitChanges(_ completionHandler: @escaping () -> Void) {
        if !Flags.shared.enablesMACESetting && !visibleSections.contains(.development) {
            pendingPreferences.mace = false
        }
        
        pendingVPNAction = pendingPreferences.requiredVPNAction()

        guard let action = pendingVPNAction else {
            commitAppPreferences()
            completionHandler()
            return
        }
        
        var forceDisconnect = true
        if self.pendingPreferences.vpnType != Client.providers.vpnProvider.currentVPNType {
            forceDisconnect = false
        }
        
        let isDisconnected = (Client.providers.vpnProvider.vpnStatus == .disconnected)
        let completionHandlerAfterVPNAction: (Bool) -> Void = { (shouldReconnect) in
            self.showLoadingAnimation()
            action.execute { (error) in
                self.pendingVPNAction = nil
                
                if shouldReconnect && !isDisconnected {
                    Client.providers.vpnProvider.reconnect(after: nil, forceDisconnect: forceDisconnect) { (error) in
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
        AppPreferences.shared.piaSocketType = pendingOpenVPNSocketType
        AppPreferences.shared.piaHandshake = pendingHandshake
    }
    
    private func commitPreferences() {
        commitAppPreferences()
        pendingPreferences.commit()
    }
    
    // MARK: Unwind segues
    
    @IBAction private func unwoundContentBlockerViewController(_ segue: UIStoryboardSegue) {
    }

    // MARK: Development
    
//    private func truncateDebugLog() {
//        connectionBusiness.truncateTunnelSnapshot()
//    }
    
//    private func recalculatePingTimes() {
//        PingerDaemon.shared.pingAllRegions()
//    }
    
//    private func invokeMACERequest() {
//        PIAEphemeralClient.shared()!.enableMACE(nil)
//    }
    
    private func resolveGoogleAdsDomain() {
        let resolver = DNSResolver(hostname: "google-analytics.com")
        resolver.resolve { (entries, error) in
            let addresses: [String]
            if let entries = entries, !entries.isEmpty {
                addresses = entries
            } else {
                addresses = ["Can't resolve"]
            }
            
            let alert = Macros.alert(nil, addresses.joined(separator: ","))
            alert.addDefaultAction(L10n.Global.close)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Helpers
    
    @objc private func redisplaySettings() {
        var sections = SettingsViewController.allSections
        if !Flags.shared.enablesProtocolSelection {
            sections.remove(at: sections.firstIndex(of: .connection)!)
            sections.remove(at: sections.firstIndex(of: .encryption)!)
        } else {
            if (pendingPreferences.vpnType == IKEv2Profile.vpnType ||
                pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType) {
                sections.remove(at: sections.firstIndex(of: .encryption)!)
            }
            if (pendingPreferences.vpnType == PIATunnelProfile.vpnType ||
                pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType) {
                sections.remove(at: sections.firstIndex(of: .ikeV2encryption)!)
            }
        }
        if Flags.shared.enablesMACESetting {
            rowsBySection[.applicationSettings] = [
                .automaticReconnection,
                .mace
            ]
        } else {
            rowsBySection[.applicationSettings] = [
                .automaticReconnection,
            ]
        }
        
        if Flags.shared.enablesThemeSwitch {
            rowsBySection[.applicationSettings]?.insert(.darkTheme, at: 0)
        }
        
        if #available(iOS 12.0, *) {
            rowsBySection[.applicationSettings]?.insert(contentsOf: [.connectShortcut, .disconnectShortcut], at: 0)
        }

        if (pendingPreferences.vpnType == PIATunnelProfile.vpnType) {
            rowsBySection[.smallPackets] = [.useSmallPackets]
        } else {
            rowsBySection[.smallPackets] = []
            sections.remove(at: sections.firstIndex(of: .smallPackets)!)
        }
        
        if !Flags.shared.enablesContentBlockerSetting {
            sections.remove(at: sections.firstIndex(of: .contentBlocker)!)
        }
        if (pendingPreferences.vpnType != PIATunnelProfile.vpnType &&
            pendingPreferences.vpnType != PIAWGTunnelProfile.vpnType) {
            sections.remove(at: sections.firstIndex(of: .applicationInformation)!)
        }
        if !Flags.shared.enablesResetSettings {
            sections.remove(at: sections.firstIndex(of: .reset)!)
        }
        if Flags.shared.enablesDevelopmentSettings {
            sections.append(.development)
        }
        visibleSections = sections
        
        let dnsSettingsEnabled = Flags.shared.enablesDNSSettings

        if (pendingPreferences.vpnType == PIATunnelProfile.vpnType) {
            rowsBySection[.connection] = dnsSettingsEnabled ?
                [.vpnProtocolSelection, .vpnSocket, .vpnPort, .vpnDns] :
                [.vpnProtocolSelection, .vpnSocket, .vpnPort]
        } else if (pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType) {
            rowsBySection[.connection] = dnsSettingsEnabled ?
                [.vpnProtocolSelection, .vpnDns] :
                [.vpnProtocolSelection]
        } else {
            rowsBySection[.connection] = [
                .vpnProtocolSelection
            ]
        }
        
        tableView.reloadData()
    }
    
    private func reportUpdatedPreferences() {
        pendingVPNAction = pendingPreferences.requiredVPNAction()
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
        if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
            if Flags.shared.enablesDNSSettings {
                       var isValid = false
                       for dns in DNSList.shared.dnsList {
                           for (_, value) in dns {
                               if pendingWireguardVPNConfiguration.customDNSServers == value {
                                   isValid = true
                                   break
                               }
                           }
                       }
                       if !isValid {
                           pendingWireguardVPNConfiguration = PIAWireguardConfiguration(customDNSServers: [])
                       }
            }
        } else {
            if Flags.shared.enablesDNSSettings {
                       var isValid = false
                       for dns in DNSList.shared.dnsList {
                           for (_, value) in dns {
                               if pendingOpenVPNConfiguration.dnsServers == value {
                                   isValid = true
                                   break
                               }
                           }
                       }
                       if !isValid {
                           pendingOpenVPNConfiguration.dnsServers = []
                       }
            }
        }
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return visibleSections.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Cells.header),
            let label = cell.textLabel {
            
            label.style(style: TextStyle.textStyle9)
            label.font = UIFont.mediumFontWith(size: 14.0)

            switch visibleSections[section] {
            case .connection:
                label.text =  "VPN Settings".uppercased()

            case .applicationSettings:
                label.text =  "General Settings".uppercased()

            default:
                return nil
            }
            
            return cell
        }
        return nil

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch visibleSections[section] {

        case .connection:
            return nil
            
        case .encryption:
            return L10n.Settings.Encryption.title

        case .ikeV2encryption:
            return L10n.Settings.Encryption.title

        case .applicationSettings:
            return nil
           
        case .autoConnectSettings:
            return nil

        case .geoSettings:
            return nil

        case .smallPackets:
            return nil
            
        case .contentBlocker:
            return L10n.Settings.ContentBlocker.title

        case .applicationInformation:
            return L10n.Settings.ApplicationInformation.title

        case .reset:
            return L10n.Settings.Reset.title

        case .preview:
            return L10n.Settings.Preview.title

        case .development:
            return "DEVELOPMENT"
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Cells.footer) {
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.style(style: TextStyle.textStyle21)
            
            switch visibleSections[section] {
            case .applicationSettings:
                var footer: [String] = [
                    L10n.Settings.ApplicationSettings.KillSwitch.footer
                ]
                if Flags.shared.enablesMACESetting {
                    footer.append(L10n.Settings.ApplicationSettings.Mace.footer)
                }
                cell.textLabel?.text = footer.joined(separator: "\n\n")

            case .autoConnectSettings:
                cell.textLabel?.text =  L10n.Settings.Hotspothelper.description

            case .smallPackets:
                if (pendingPreferences.vpnType == PIATunnelProfile.vpnType) {
                    cell.textLabel?.text = L10n.Settings.Small.Packets.description
                } else {
                    return nil
                }
                
            case .reset:
                cell.textLabel?.text = L10n.Settings.Reset.footer

            case .contentBlocker:
                cell.textLabel?.text = L10n.Settings.ContentBlocker.footer
                
            default:
                return nil
            }
            
            return cell
        }
        return nil

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsBySection[visibleSections[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        let section = visibleSections[indexPath.section]
        guard let setting = rowsBySection[section]?[indexPath.row] else {
            fatalError("Data source is incorrect")
        }
        switch setting {
        case .username, .publicUsername, .password:
            return true
        default:
            return false
        }
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            let cell = tableView.cellForRow(at: indexPath)
            let pasteboard = UIPasteboard.general
            pasteboard.string = cell?.detailTextLabel?.text
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.setting, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil
        cell.selectionStyle = .default

        let section = visibleSections[indexPath.section]
        guard let setting = rowsBySection[section]?[indexPath.row] else {
            fatalError("Data source is incorrect")
        }
        
        switch setting {
        case .vpnProtocolSelection:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.protocolCell, for: indexPath) as! ProtocolTableViewCell
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
            cell.selectionStyle = .default

            cell.setupCell(withTitle: L10n.Settings.Connection.VpnProtocol.title,
                           description: pendingPreferences.vpnType.vpnTypeDescription,
                           shouldShowBadge: pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType)

            if !Flags.shared.enablesProtocolSelection {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }
            
            Theme.current.applySecondaryBackground(cell)
            let backgroundView = UIView()
            Theme.current.applyPrincipalBackground(backgroundView)
            cell.selectedBackgroundView = backgroundView
            return cell

        case .vpnSocket:
            cell.textLabel?.text = L10n.Settings.Connection.SocketProtocol.title
            cell.detailTextLabel?.text = pendingOpenVPNSocketType?.description ?? L10n.Global.automatic
            
        case .vpnPort:
            cell.textLabel?.text = L10n.Settings.Connection.RemotePort.title
            guard pendingOpenVPNSocketType != nil else {
                cell.detailTextLabel?.text = L10n.Global.automatic
                break
            }
            cell.detailTextLabel?.text = pendingOpenVPNConfiguration.currentPort?.description ?? L10n.Global.automatic

        case .vpnDns:
            cell.textLabel?.text = SettingsViewController.DNS
            
            var dnsValue = pendingOpenVPNConfiguration.dnsServers
            if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
                dnsValue = pendingWireguardVPNConfiguration.customDNSServers
            }
            for dns in DNSList.shared.dnsList {
                for (key, value) in dns {
                    if dnsValue == value {
                        cell.detailTextLabel?.text = DNSList.shared.descriptionForKey(key, andCustomKey: (pendingPreferences.vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY))
                        break
                    }
                }
            }
            
            if !Flags.shared.enablesDNSSettings {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }

        case .encryptionCipher:
            cell.textLabel?.text = L10n.Settings.Encryption.Cipher.title
            cell.detailTextLabel?.text = pendingOpenVPNConfiguration.cipher?.description
            if !Flags.shared.enablesEncryptionSettings {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }
            
        case .ikeV2EncryptionAlgorithm:
            cell.textLabel?.text = L10n.Settings.Encryption.Cipher.title
            if let encryptionAlgorithm = IKEv2EncryptionAlgorithm(rawValue: pendingPreferences.ikeV2EncryptionAlgorithm) {
                cell.detailTextLabel?.text = encryptionAlgorithm.description()
            } else {
                pendingPreferences.ikeV2EncryptionAlgorithm = IKEv2EncryptionAlgorithm.defaultAlgorithm.rawValue
                cell.detailTextLabel?.text = IKEv2EncryptionAlgorithm.defaultAlgorithm.description()
            }
            if !Flags.shared.enablesEncryptionSettings {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }

        case .ikeV2IntegrityAlgorithm:
            cell.textLabel?.text = L10n.Settings.Encryption.Handshake.title
            cell.detailTextLabel?.text = IKEv2IntegrityAlgorithm.objectIdentifyBy(name: pendingPreferences.ikeV2IntegrityAlgorithm).description()
            if !Flags.shared.enablesEncryptionSettings {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }

        case .encryptionDigest:
            cell.textLabel?.text = L10n.Settings.Encryption.Digest.title
            guard !pendingOpenVPNConfiguration.isEncryptionGCM() else {
                cell.detailTextLabel?.text = "GCM"
                break
            }
            cell.detailTextLabel?.text = pendingOpenVPNConfiguration.digest?.description
            if !Flags.shared.enablesEncryptionSettings {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }

        case .encryptionHandshake:
            cell.textLabel?.text = L10n.Settings.Encryption.Handshake.title
            
            cell.detailTextLabel?.text = pendingHandshake.description
            if !Flags.shared.enablesEncryptionSettings {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }
            
        case .useSmallPackets:
            cell.textLabel?.text = L10n.Settings.Small.Packets.title
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchSmallPackets
            cell.selectionStyle = .none
            switchSmallPackets.isOn = AppPreferences.shared.useSmallPackets

        case .automaticReconnection:
            cell.textLabel?.text = L10n.Settings.ApplicationSettings.KillSwitch.title
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchPersistent
            cell.selectionStyle = .none
            switchPersistent.isOn = pendingPreferences.isPersistentConnection

        case .serversNetwork:
            cell.textLabel?.text = L10n.Settings.Server.Network.description
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchServersNetwork
            cell.selectionStyle = .none
            switchServersNetwork.isOn = Client.configuration.currentServerNetwork() == ServersNetwork.gen4

        case .geoServers:
            cell.textLabel?.text = L10n.Settings.Geo.Servers.description
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchGeoServers
            cell.selectionStyle = .none
            switchGeoServers.isOn = AppPreferences.shared.showGeoServers

        case .mace:
            cell.textLabel?.text = L10n.Settings.ApplicationSettings.Mace.title
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchMACE
            cell.selectionStyle = .none
            switchMACE.isOn = pendingPreferences.mace
            
        case .contentBlockerState:
            cell.textLabel?.text = L10n.Settings.ContentBlocker.State.title
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchContentBlocker
            cell.selectionStyle = .none
            switchContentBlocker.isOn = isContentBlockerEnabled

        case .contentBlockerRefreshRules:
            cell.textLabel?.text = L10n.Settings.ContentBlocker.Refresh.title
            cell.detailTextLabel?.text = nil
            
        case .darkTheme:
            cell.textLabel?.text = L10n.Settings.ApplicationSettings.DarkTheme.title
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchDarkMode
            cell.selectionStyle = .none
            switchDarkMode.isOn = (AppPreferences.shared.currentThemeCode == .dark)

        case .connectShortcut:
            cell.textLabel?.text = L10n.Siri.Shortcuts.Connect.Row.title
            cell.detailTextLabel?.text = SiriShortcutsManager.shared.descriptionActionForConnectShortcut()

        case .disconnectShortcut:
            cell.textLabel?.text = L10n.Siri.Shortcuts.Disconnect.Row.title
            cell.detailTextLabel?.text = SiriShortcutsManager.shared.descriptionActionForDisconnectShortcut()

        case .sendDebugLog:
            cell.textLabel?.text = L10n.Settings.ApplicationInformation.Debug.title
            cell.detailTextLabel?.text = nil
            
        case .resetSettings:
            cell.textLabel?.text = L10n.Settings.Reset.Defaults.title
            cell.detailTextLabel?.text = nil

//        case .truncateDebugLog:
//            cell.textLabel?.text = "Truncate debug log (disconnect first)"
//            cell.detailTextLabel?.text = nil
//
//        case .recalculatePingTimes:
//            cell.textLabel?.text = "Recalculate ping times (disconnect first)"
//            cell.detailTextLabel?.text = nil
//
//        case .invokeMACERequest:
//            cell.textLabel?.text = "Invoke MACE request"
//            cell.detailTextLabel?.text = nil

        case .resolveGoogleAdsDomain:
            cell.textLabel?.text = "Resolve google-analytics.com"
            cell.detailTextLabel?.text = nil
            
        case .trustedNetworks:
            cell.textLabel?.text = L10n.Settings.Hotspothelper.title
            cell.detailTextLabel?.text = nil

        case .publicUsername:
            cell.textLabel?.text = "Public username"
            cell.detailTextLabel?.text = Client.providers.accountProvider.publicUsername ?? ""
            cell.accessoryType = .none
        case .username:
            cell.textLabel?.text = "Username"
            cell.detailTextLabel?.text = Client.providers.accountProvider.currentUser?.credentials.username ?? ""
            cell.accessoryType = .none
        case .password:
            cell.textLabel?.text = "Password"
            cell.detailTextLabel?.text = Client.providers.accountProvider.currentUser?.credentials.password ?? ""
            cell.accessoryType = .none
        case .customServers:
            cell.textLabel?.text = "Custom Servers"
            cell.detailTextLabel?.text = nil

        }
        

        Theme.current.applySecondaryBackground(cell)
        if let textLabel = cell.textLabel {
            Theme.current.applySettingsCellTitle(textLabel,
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
        let section = visibleSections[indexPath.section]
        guard let setting = rowsBySection[section]?[indexPath.row] else {
            fatalError("Data source is incorrect")
        }

        var controller: OptionsViewController?
        
        switch setting {
        case .vpnProtocolSelection:
            
            controller = OptionsViewController()

            if #available(iOS 12.0, *) {
                controller?.options = [
                    IKEv2Profile.vpnType,
                    PIAWGTunnelProfile.vpnType, //WG only available for iOS12+
                    PIATunnelProfile.vpnType,
                ]
            } else {
                controller?.options = [
                    IKEv2Profile.vpnType,
                    PIATunnelProfile.vpnType,
                ]
            }
            controller?.selectedOption = pendingPreferences.vpnType
            
        case .vpnSocket:
            let options: [SocketType] = [
                .udp,
                .tcp
            ]
            controller = OptionsViewController()
            controller?.options = options.map { $0.rawValue }
            controller?.options.insert(SettingsViewController.AUTOMATIC_SOCKET, at: 0)
            controller?.selectedOption = pendingOpenVPNSocketType?.rawValue ?? SettingsViewController.AUTOMATIC_SOCKET

        case .vpnPort:
            guard let socketType = pendingOpenVPNSocketType else {
                break
            }
            let availablePorts = Client.providers.serverProvider.currentServersConfiguration.ovpnPorts
            var options = (socketType == .udp) ? availablePorts.udp : availablePorts.tcp
            options.insert(SettingsViewController.AUTOMATIC_PORT, at: 0)
            controller = OptionsViewController()
            controller?.options = options
            controller?.selectedOption = pendingOpenVPNConfiguration.currentPort ?? SettingsViewController.AUTOMATIC_PORT

        case .vpnDns:
            guard Flags.shared.enablesDNSSettings else {
                break
            }
            
            controller = OptionsViewController()
            if let dnsList = DNSList.shared.dnsList {
                let filtered = dnsList.filter({
                    if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
                        return $0.first?.key != DNSList.CUSTOM_WIREGUARD_DNS_KEY
                    } else {
                        return $0.first?.key != DNSList.CUSTOM_OPENVPN_DNS_KEY
                    }
                })
                controller?.options = filtered.compactMap {
                    if let first = $0.first {
                        return first.key
                    }
                    return nil
                }
            }
            
            if let options = controller?.options,
                !options.contains(pendingPreferences.vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY) {
                if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
                    controller?.options.append(DNSList.CUSTOM_OPENVPN_DNS_KEY)
                } else {
                    controller?.options.append(DNSList.CUSTOM_WIREGUARD_DNS_KEY)
                }
            } else {
                for dns in DNSList.shared.dnsList {
                    for (key, value) in dns {
                        if key == (pendingPreferences.vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY) {
                            if !value.isEmpty {
                                controller?.navigationItem.rightBarButtonItem = UIBarButtonItem(
                                    title: L10n.Global.edit,
                                    style: .plain,
                                    target: self,
                                    action: #selector(edit(_:))
                                )
                            }
                        }
                    }
                }
            }
            
            if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
                controller?.selectedOption = pendingWireguardVPNConfiguration.customDNSServers
            } else {
                controller?.selectedOption = pendingOpenVPNConfiguration.dnsServers
            }
            
        case .ikeV2EncryptionAlgorithm:
            guard Flags.shared.enablesEncryptionSettings else {
                break
            }
            let options = IKEv2EncryptionAlgorithm.allValues()
            if #available(iOS 13, *) {
                //options.append(NEVPNIKEv2EncryptionAlgorithm.algorithmChaCha20Poly1305)
            }
            controller = OptionsViewController()
            controller?.options = options.map { $0.description() }
            
            if let encryptionAlgorithm = IKEv2EncryptionAlgorithm(rawValue: pendingPreferences.ikeV2EncryptionAlgorithm) {
                controller?.selectedOption = encryptionAlgorithm.rawValue
            } else {
                controller?.selectedOption = IKEv2EncryptionAlgorithm.defaultAlgorithm.rawValue
            }

        case .ikeV2IntegrityAlgorithm:
            guard Flags.shared.enablesEncryptionSettings else {
                break
            }
            
            var options = IKEv2EncryptionAlgorithm.defaultAlgorithm.integrityAlgorithms()

            if let encryptionAlgorithm = IKEv2EncryptionAlgorithm(rawValue: pendingPreferences.ikeV2EncryptionAlgorithm) {
                options = encryptionAlgorithm.integrityAlgorithms()
            } else {
                options = IKEv2EncryptionAlgorithm.defaultAlgorithm.integrityAlgorithms()
            }
            
            controller = OptionsViewController()
            controller?.options = options.map { $0.description() }
            controller?.selectedOption = IKEv2IntegrityAlgorithm.objectIdentifyBy(name: pendingPreferences.ikeV2IntegrityAlgorithm).rawValue

        case .encryptionCipher:
            guard Flags.shared.enablesEncryptionSettings else {
                break
            }
            let options: [OpenVPN.Cipher] = [
                .aes128gcm,
                .aes256gcm,
                .aes128cbc,
                .aes256cbc
            ]
            controller = OptionsViewController()
            controller?.options = options.map { $0.rawValue }
            controller?.selectedOption = pendingOpenVPNConfiguration.cipher?.rawValue

        case .encryptionDigest:
            guard Flags.shared.enablesEncryptionSettings else {
                break
            }
            guard !pendingOpenVPNConfiguration.isEncryptionGCM() else {
                break
            }
            let options: [OpenVPN.Digest] = [
                .sha1,
                .sha256
            ]
            controller = OptionsViewController()
            controller?.options = options.map { $0.rawValue }
            controller?.selectedOption = pendingOpenVPNConfiguration.digest?.rawValue

        case .encryptionHandshake:
            guard Flags.shared.enablesEncryptionSettings else {
                break
            }
            let options: [OpenVPN.Configuration.Handshake] = [
                .rsa2048,
                .rsa3072,
                .rsa4096,
                .ecc256r1,
                .ecc521r1
            ]
            controller = OptionsViewController()
            controller?.options = options.map { $0.rawValue }
            controller?.selectedOption = pendingHandshake.description
            
        case .contentBlockerState:
            if #available(iOS 10, *) {
                
            } else {
                showContentBlockerTutorial()
            }
            
        case .contentBlockerRefreshRules:
            refreshContentBlockerRules()

        case .sendDebugLog:
            submitTunnelLog()
            
        case .resetSettings:
            resetToDefaultSettings()

//        case .truncateDebugLog:
//            truncateDebugLog()
//
//        case .recalculatePingTimes:
//            recalculatePingTimes()
//
//        case .invokeMACERequest:
//            invokeMACERequest()

        case .resolveGoogleAdsDomain:
            resolveGoogleAdsDomain()

        case .trustedNetworks:
            self.perform(segue: StoryboardSegue.Main.trustedNetworksSegueIdentifier)

        case .customServers:
            self.perform(segue: StoryboardSegue.Main.customServerSegueIdentifier)

        case .connectShortcut:
            if #available(iOS 12.0, *) {
                SiriShortcutsManager.shared.presentConnectShortcut(inViewController: self)
            }

        case .disconnectShortcut:
            if #available(iOS 12.0, *) {
                SiriShortcutsManager.shared.presentDisconnectShortcut(inViewController: self)
            }

        default:
            break
        }

        if let controller = controller {
            guard let cell = tableView.cellForRow(at: indexPath) else {
                fatalError("Cell not found at \(indexPath)")
            }

            controller.title = cell.textLabel?.text
            controller.tag = setting.rawValue
            controller.delegate = self

            parent?.navigationItem.setEmptyBackButton()
            navigationController?.pushViewController(controller, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionHeader(view)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionFooter(view)
    }

}

extension SettingsViewController: OptionsViewControllerDelegate {
    func backgroundColorForOptionsController(_ controller: OptionsViewController) -> UIColor {
        return Theme.current.palette.principalBackground
    }
    
    func tableStyleForOptionsController(_ controller: OptionsViewController) -> UITableView.Style {
        return .grouped
    }
    
    func optionsController(_ controller: OptionsViewController, didLoad tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }

    func optionsController(_ controller: OptionsViewController, tableView: UITableView, reusableCellAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
    
    func optionsController(_ controller: OptionsViewController, renderOption option: AnyHashable, in cell: UITableViewCell, at row: Int, isSelected: Bool) {
        guard let setting = Setting(rawValue: controller.tag) else {
            fatalError("Unhandled setting \(controller.tag)")
        }

        switch setting {
        case .vpnProtocolSelection:
            let vpnType = option as! String
            var message = vpnType.vpnTypeDescription
            if vpnType == PIAWGTunnelProfile.vpnType {
                message += " - PREVIEW"
            }
            cell.textLabel?.text = message
        case .vpnSocket:
            let rawSocketType = option as? String
            if rawSocketType != SettingsViewController.AUTOMATIC_SOCKET {
                cell.textLabel?.text = rawSocketType?.description
            } else {
                cell.textLabel?.text = L10n.Global.automatic
            }
            
        case .vpnPort:
            if let port = option as? UInt16, (port != SettingsViewController.AUTOMATIC_PORT) {
                cell.textLabel?.text = (option as? UInt16)?.description
            } else {
                cell.textLabel?.text = L10n.Global.automatic
            }
            
        case .vpnDns:
            if let option = option as? String {
                cell.textLabel?.text = DNSList.shared.descriptionForKey(option, andCustomKey: pendingPreferences.vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY)
                if option == (pendingPreferences.vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY) {
                    var isFound = false
                    for dns in DNSList.shared.dnsList {
                        for (key, value) in dns {
                            if key == option {
                                isFound = true
                                if value.isEmpty {
                                    cell.accessoryType = .disclosureIndicator
                                }
                            }
                        }
                    }
                    if !isFound { //first time
                        cell.accessoryType = .disclosureIndicator
                    }
                }
            }
        case .encryptionCipher:
            let rawCipher = option as! String
            cell.textLabel?.text = OpenVPN.Cipher(rawValue: rawCipher)?.description

        case .encryptionDigest:
            let rawDigest = option as! String
            cell.textLabel?.text = OpenVPN.Digest(rawValue: rawDigest)?.description

        case .ikeV2EncryptionAlgorithm, .ikeV2IntegrityAlgorithm:
            cell.textLabel?.text = option as? String
            
        case .encryptionHandshake:
            let rawHandshake = option as! String
            cell.textLabel?.text = OpenVPN.Configuration.Handshake(rawValue: rawHandshake)?.description

        default:
            break
        }
        
        cell.accessoryView = (isSelected ? imvSelectedOption : nil)

        if setting == .vpnDns,
            let option = option as? String {
            
            var dnsJoinedValue = pendingOpenVPNConfiguration.dnsServers?.joined()
            if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
                dnsJoinedValue = pendingWireguardVPNConfiguration.customDNSServers.joined()
            }

            for dns in DNSList.shared.dnsList {
                for (key, value) in dns {
                    if key == option,
                        dnsJoinedValue == value.joined() {
                        cell.accessoryView = imvSelectedOption
                    }
                }
            }
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Theme.current.palette.principalBackground
        cell.selectedBackgroundView = backgroundView

        Theme.current.applySecondaryBackground(cell)
        Theme.current.applyDetailTableCell(cell)
    }

    func optionsController(_ controller: OptionsViewController, didSelectOption option: AnyHashable, at row: Int) {
        guard let setting = Setting(rawValue: controller.tag) else {
            fatalError("Unhandled setting \(controller.tag)")
        }

        let serversCfg = Client.providers.serverProvider.currentServersConfiguration

        switch setting {
        case .vpnProtocolSelection:
            let vpnType = option as! String
            pendingPreferences.vpnType = vpnType
            
        case .vpnSocket:
            let rawSocketType = option as! String
            let optSocketType = SocketType(rawValue: rawSocketType)

            let currentProtocols = pendingOpenVPNConfiguration.endpointProtocols
            var newProtocols: [EndpointProtocol] = []

            if let socketType = optSocketType {
                let ports = (socketType == .udp) ? serversCfg.ovpnPorts.udp : serversCfg.ovpnPorts.tcp
                if currentProtocols?.count == 1, let currentPort = pendingOpenVPNConfiguration?.currentPort, ports.contains(currentPort) {
                    newProtocols.append(EndpointProtocol(socketType, currentPort))
                } else {
                    for port in ports {
                        newProtocols.append(EndpointProtocol(socketType, port))
                    }
                }
            } else {
//                for port in serversCfg.vpnPorts.udp {
//                    newProtocols.append(PIATunnelProvider.EndpointProtocol(.udp, port, .pia))
//                }
//                for port in serversCfg.vpnPorts.tcp {
//                    newProtocols.append(PIATunnelProvider.EndpointProtocol(.tcp, port, .pia))
//                }
                newProtocols = AppConfiguration.VPN.piaAutomaticProtocols
            }
            pendingOpenVPNSocketType = optSocketType
            pendingOpenVPNConfiguration.endpointProtocols = newProtocols

        case .vpnPort:
            let port = option as! UInt16

            var newProtocols: [EndpointProtocol] = []
            if (port != SettingsViewController.AUTOMATIC_PORT) {
                guard let socketType = pendingOpenVPNSocketType else {
                    fatalError("Port cannot be set manually when socket type is automatic")
                }
                newProtocols.append(EndpointProtocol(socketType, port))
            } else {
                if (pendingOpenVPNSocketType == nil) {
                    newProtocols = AppConfiguration.VPN.piaAutomaticProtocols
                }
                else if (pendingOpenVPNSocketType == .udp) {
                    for port in serversCfg.ovpnPorts.udp {
                        newProtocols.append(EndpointProtocol(.udp, port))
                    }
                }
                else if (pendingOpenVPNSocketType == .tcp) {
                    for port in serversCfg.ovpnPorts.tcp {
                        newProtocols.append(EndpointProtocol(.tcp, port))
                    }
                }
            }
            pendingOpenVPNConfiguration.endpointProtocols = newProtocols

        case .vpnDns:
            if let option = option as? String {
                var isFound = false
                
                for dns in DNSList.shared.dnsList {
                    for (key, value) in dns {
                        if key == option {
                            isFound = true
                            if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
                                pendingWireguardVPNConfiguration = PIAWireguardConfiguration(customDNSServers: value)
                            } else {
                                pendingOpenVPNConfiguration.dnsServers = value
                            }
                            break
                        }
                    }
                }
                
                if !isFound && option == (pendingPreferences.vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY) {
                    let alertController = Macros.alert(L10n.Settings.Dns.Custom.dns,
                                                       L10n.Settings.Dns.Alert.Create.message)
                    alertController.addActionWithTitle(L10n.Global.ok) {
                        self.perform(segue: StoryboardSegue.Main.customDNSSegueIdentifier)
                    }
                    alertController.addCancelAction(L10n.Global.cancel)
                    self.present(alertController,
                                 animated: true,
                                 completion: nil)
                }
                
            }
        case .encryptionCipher:
            let rawCipher = option as! String
            pendingOpenVPNConfiguration.cipher = OpenVPN.Cipher(rawValue: rawCipher)!

        case .encryptionDigest:
            let rawDigest = option as! String
            pendingOpenVPNConfiguration.digest = OpenVPN.Digest(rawValue: rawDigest)!

        case .ikeV2EncryptionAlgorithm:
            let rawEncryption = option as! String
            pendingPreferences.ikeV2EncryptionAlgorithm = rawEncryption
            //reset integrity algorithm if the encryption changes
            var algorithm = IKEv2EncryptionAlgorithm.defaultAlgorithm
            if let currentAlgorithm = IKEv2EncryptionAlgorithm(rawValue: rawEncryption) {
                algorithm = currentAlgorithm
            }
            if let integrity = algorithm.integrityAlgorithms().first {
                pendingPreferences.ikeV2IntegrityAlgorithm = integrity.rawValue
            }
        case .ikeV2IntegrityAlgorithm:
            let rawIntegrity = option as! String
            pendingPreferences.ikeV2IntegrityAlgorithm = rawIntegrity

        case .encryptionHandshake:
            let rawHandshake = option as! String
            if let handshake = OpenVPN.Configuration.Handshake(rawValue: rawHandshake),
                let pem = handshake.pemString() {
                pendingOpenVPNConfiguration.ca = OpenVPN.CryptoContainer(pem: pem)
                pendingHandshake = OpenVPN.Configuration.Handshake(rawValue: rawHandshake)
            }
        default:
            break
        }
        
        savePreferences()
        navigationController?.popViewController(animated: true)

    }
    
    private func savePreferences() {
        log.debug("OpenVPN endpoints: \(pendingOpenVPNConfiguration.endpointProtocols ?? [])")
        
        if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
            var builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: pendingOpenVPNConfiguration.build())
            
            if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
                if AppPreferences.shared.useSmallPackets {
                    builder.mtu = AppConstants.OpenVPNPacketSize.smallPacketSize
                } else {
                    builder.mtu = AppConstants.OpenVPNPacketSize.defaultPacketSize
                }
            }
            builder.shouldDebug = true

            pendingPreferences.setVPNCustomConfiguration(builder.build(), for: pendingPreferences.vpnType)
        } else {
            pendingPreferences.setVPNCustomConfiguration(pendingWireguardVPNConfiguration, for: pendingPreferences.vpnType)
        }

        redisplaySettings()
        reportUpdatedPreferences()
    }
}

private extension OpenVPN.ConfigurationBuilder {
//    var currentSocketType: PIATunnelProvider.SocketType {
//        guard let currentType = endpointProtocols.first?.socketType else {
//            fatalError("Zero current protocols")
//        }
//        return currentType
//    }

    var currentPort: UInt16? {
        guard endpointProtocols?.count == 1 else {
            return nil
        }
        guard let port = endpointProtocols?.first?.port else {
            fatalError("Zero current protocols")
        }
        return port
    }

    func isEncryptionGCM() -> Bool {
        return (cipher == .aes128gcm) || (cipher == .aes256gcm)
    }
}

extension SettingsViewController: SettingsViewControllerDelegate {
    
    func updateSetting(_ setting: Setting, withValue value: Any?) {
        switch setting {
        case .vpnDns:
            if let settingValue = value as? String {
                if pendingPreferences.vpnType == PIATunnelProfile.vpnType {
                    pendingOpenVPNConfiguration.dnsServers = DNSList.shared.valueForKey(settingValue)
                } else {
                    pendingWireguardVPNConfiguration = PIAWireguardConfiguration(customDNSServers: DNSList.shared.valueForKey(settingValue))
                }
            }
        default:
            break
        }
        
        savePreferences()

    }
    
}
