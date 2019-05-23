//
//  SettingsViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary
import PIATunnel
import SafariServices
import SwiftyBeaver
import Intents
import IntentsUI

private let log = SwiftyBeaver.self

private extension String {
    var vpnTypeDescription: String {
        guard (self != PIATunnelProfile.vpnType) else {
            return "OpenVPN"
        }
        return self
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
    
    case automaticReconnection

    case trustedNetworks

    case connectShortcut

    case disconnectShortcut

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

        case applicationSettings
        
        case autoConnectSettings

        case contentBlocker

        case applicationInformation
        
        case reset

        case development
    }

    private static let allSections: [Section] = [
        .connection,
        .encryption,
        .applicationSettings,
        .autoConnectSettings,
        .applicationInformation,
        .reset,
        .contentBlocker
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
            .encryptionHandshake
        ],
        .applicationSettings: [], // dynamic
        .autoConnectSettings: [
            .trustedNetworks
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
        .development: [
//            .truncateDebugLog,
//            .recalculatePingTimes,
//            .invokeMACERequest,
//            .mace,
            .publicUsername,
            .username,
            .password,
            .resolveGoogleAdsDomain
        ]
    ]
    
    private struct Cells {
        static let setting = "SettingCell"
        static let footer = "FooterCell"
    }
    
    @IBOutlet private weak var tableView: UITableView!

    private lazy var switchAutoJoinWiFi = UISwitch()

    private lazy var switchPersistent = UISwitch()

    private lazy var switchMACE = UISwitch()
    
    private lazy var switchContentBlocker = FakeSwitch()
    
    private lazy var switchDarkMode = UISwitch()
    
    private lazy var switchConnectSiriShortcuts = UISwitch()

    private lazy var switchDisconnectSiriShortcuts = UISwitch()

    private lazy var imvSelectedOption = UIImageView(image: Asset.accessorySelected.image)

    private var isContentBlockerEnabled = false

//    private lazy var buttonConfirm = UIBarButtonItem(
//        barButtonSystemItem: .save,
//        target: self,
//        action: #selector(confirmChangesImmediately(_:))
//    )
    
    private var pendingPreferences: Client.Preferences.Editable!
    
    private var pendingOpenVPNSocketType: PIATunnelProvider.SocketType?
    
    private var pendingOpenVPNConfiguration: PIATunnelProvider.ConfigurationBuilder!

    private var pendingVPNAction: VPNAction?
//    private var pendingVPNAction: VPNAction? {
//        didSet {
//            if let _ = pendingVPNAction {
//                buttonConfirm.isEnabled = true
//            } else {
//                buttonConfirm.isEnabled = false
//            }
//        }
//    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//        buttonConfirm.isEnabled = false
//        navigationItem.rightBarButtonItem = buttonConfirm
        
        pendingPreferences = Client.preferences.editable()

        // XXX: fall back to default configuration (don't rely on client library)
        guard let currentOpenVPNConfiguration = pendingPreferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? PIATunnelProvider.Configuration ??
            Client.preferences.defaults.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? PIATunnelProvider.Configuration else {

            fatalError("No default VPN custom configuration provided for PIA protocol")
        }
        pendingOpenVPNSocketType = AppPreferences.shared.piaSocketType
        pendingOpenVPNConfiguration = currentOpenVPNConfiguration.builder()
        
        validateDNSList()

        if #available(iOS 11, *) {
            tableView.sectionFooterHeight = UITableView.automaticDimension
            tableView.estimatedSectionFooterHeight = 1.0
        }
        switchPersistent.addTarget(self, action: #selector(togglePersistentConnection(_:)), for: .valueChanged)
        switchMACE.addTarget(self, action: #selector(toggleMACE(_:)), for: .valueChanged)
//        switchContentBlocker.isGrayed = true
        switchContentBlocker.addTarget(self, action: #selector(showContentBlockerTutorial), for: .touchUpInside)
        switchDarkMode.addTarget(self, action: #selector(toggleDarkMode(_:)), for: .valueChanged)
        switchConnectSiriShortcuts.addTarget(self, action: #selector(toggleConnectSiriShortcuts(_:)), for: .valueChanged)
        switchDisconnectSiriShortcuts.addTarget(self, action: #selector(toggleDisconnectSiriShortcuts(_:)), for: .valueChanged)
        redisplaySettings()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshContentBlockerState), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPersistentConnectionValue),
                                               name: .PIAPersistentConnectionSettingHaveChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewHasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshContentBlockerState()
        styleNavigationBarWithTitle(L10n.Menu.Item.settings)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if #available(iOS 11, *) {
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let customDNSSettingsVC = segue.destination as? CustomDNSSettingsViewController {
            customDNSSettingsVC.delegate = self
            let ips = DNSList.shared.valueForKey(DNSList.CUSTOM_DNS_KEY)
            if ips.count > 0 {
                customDNSSettingsVC.primaryDNSValue = ips.first
                if ips.count > 1 {
                    customDNSSettingsVC.secondaryDNSValue = ips.last
                }
            }
        } else if let trustedNetworksVC = segue.destination as? TrustedNetworksViewController {
            trustedNetworksVC.persistentConnectionValue = pendingPreferences.isPersistentConnection
        }
    }
    
    // MARK: Actions
    @objc private func edit(_ sender: Any?) {
        self.perform(segue: StoryboardSegue.Main.customDNSSegueIdentifier)
    }

    @objc private func togglePersistentConnection(_ sender: UISwitch) {
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
    
    @objc private func toggleConnectSiriShortcuts(_ sender: UISwitch) {
        if #available(iOS 12.0, *) {
            
            if AppPreferences.shared.useConnectSiriShortcuts {
                if let shortcut = AppPreferences.shared.connectShortcut {
                    let vc = INUIEditVoiceShortcutViewController(voiceShortcut: shortcut)
                    vc.delegate = self
                    present(vc, animated: true, completion: nil)
                }
            } else {
                let connectActivity = NSUserActivity(activityType: AppConstants.SiriShortcuts.shortcutConnect)
                connectActivity.title = L10n.Siri.Shortcuts.Connect.title
                connectActivity.isEligibleForSearch = true
                connectActivity.isEligibleForPrediction = true
                connectActivity.persistentIdentifier = NSUserActivityPersistentIdentifier(AppConstants.SiriShortcuts.shortcutConnect)
                let connectShortcut = INShortcut(userActivity: connectActivity)
                
                let vc = INUIAddVoiceShortcutViewController(shortcut: connectShortcut)
                vc.delegate = self
                present(vc, animated: true, completion: nil)
            }

            tableView.reloadData()
        }
    }
    
    @objc private func toggleDisconnectSiriShortcuts(_ sender: UISwitch) {
        if #available(iOS 12.0, *) {
            
            if AppPreferences.shared.useDisconnectSiriShortcuts {
                if let shortcut = AppPreferences.shared.disconnectShortcut {
                    let vc = INUIEditVoiceShortcutViewController(voiceShortcut: shortcut)
                    vc.delegate = self
                    present(vc, animated: true, completion: nil)
                }
            } else {
                let disconnectActivity = NSUserActivity(activityType: AppConstants.SiriShortcuts.shortcutDisconnect)
                disconnectActivity.title = L10n.Siri.Shortcuts.Disconnect.title
                disconnectActivity.isEligibleForSearch = true
                disconnectActivity.isEligibleForPrediction = true
                disconnectActivity.persistentIdentifier = NSUserActivityPersistentIdentifier(AppConstants.SiriShortcuts.shortcutDisconnect)
                let disconnectShortcut = INShortcut(userActivity: disconnectActivity)
                
                let vc = INUIAddVoiceShortcutViewController(shortcut: disconnectShortcut)
                vc.delegate = self
                present(vc, animated: true, completion: nil)
            }
            
            tableView.reloadData()

        }
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
        preferences.commit()

        guard let currentOpenVPNConfiguration = pendingPreferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? PIATunnelProvider.Configuration else {
            fatalError("No default VPN custom configuration provided for PIA protocol")
        }
        AppPreferences.shared.reset()
        DNSList.shared.resetPlist()
        pendingOpenVPNSocketType = AppPreferences.shared.piaSocketType
        pendingOpenVPNConfiguration = currentOpenVPNConfiguration.builder()

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
            commitPreferences()
            completionHandler()
            return
        }
        
        let isDisconnected = (Client.providers.vpnProvider.vpnStatus == .disconnected)
        let completionHandlerAfterVPNAction: (Bool) -> Void = { (shouldReconnect) in
            self.showLoadingAnimation()
            action.execute { (error) in
                self.pendingVPNAction = nil
                
                Client.providers.vpnProvider.updatePreferences(nil)
                
                if shouldReconnect && !isDisconnected {
                    Client.providers.vpnProvider.reconnect(after: nil) { (error) in
                        completionHandler()
                        self.hideLoadingAnimation()
                    }
                } else {
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
    
    private func commitPreferences() {
        AppPreferences.shared.piaSocketType = pendingOpenVPNSocketType
        //Update with values from Trusted Network Settings
        pendingPreferences.trustedNetworks = Client.preferences.trustedNetworks
        pendingPreferences.nmtRulesEnabled = Client.preferences.nmtRulesEnabled
        pendingPreferences.availableNetworks = Client.preferences.availableNetworks
        pendingPreferences.shouldConnectForAllNetworks = Client.preferences.shouldConnectForAllNetworks
        pendingPreferences.useWiFiProtection = Client.preferences.useWiFiProtection
        pendingPreferences.trustCellularData = Client.preferences.trustCellularData
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
            sections.remove(at: sections.index(of: .connection)!)
            sections.remove(at: sections.index(of: .encryption)!)
        } else {
            if (pendingPreferences.vpnType == IPSecProfile.vpnType ||
                pendingPreferences.vpnType == IKEv2Profile.vpnType) {
                sections.remove(at: sections.index(of: .encryption)!)
            }
        }
        if Flags.shared.enablesMACESetting {
            rowsBySection[.applicationSettings] = [
                .darkTheme,
                .automaticReconnection,
                .mace
            ]
        } else {
            rowsBySection[.applicationSettings] = [
                .darkTheme,
                .automaticReconnection,
            ]
        }
        
        if #available(iOS 12.0, *) {
            rowsBySection[.applicationSettings]?.insert(contentsOf: [.connectShortcut, .disconnectShortcut], at: 0)
        }
        
        if !Flags.shared.enablesContentBlockerSetting {
            sections.remove(at: sections.index(of: .contentBlocker)!)
        }
        if (pendingPreferences.vpnType != PIATunnelProfile.vpnType) {
            sections.remove(at: sections.index(of: .applicationInformation)!)
        }
        if !Flags.shared.enablesResetSettings {
            sections.remove(at: sections.index(of: .reset)!)
        }
        if Flags.shared.enablesDevelopmentSettings {
            sections.append(.development)
        }
        visibleSections = sections
        
        if (pendingPreferences.vpnType == PIATunnelProfile.vpnType) {
            
            let dnsSettingsEnabled = Flags.shared.enablesDNSSettings
            
            rowsBySection[.connection] = dnsSettingsEnabled ?
                [.vpnProtocolSelection, .vpnSocket, .vpnPort, .vpnDns] :
                [.vpnProtocolSelection, .vpnSocket, .vpnPort]
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

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return visibleSections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch visibleSections[section] {
        case .connection:
            return L10n.Settings.Connection.title
            
        case .encryption:
            return L10n.Settings.Encryption.title
            
        case .applicationSettings:
            return L10n.Settings.ApplicationSettings.title
           
        case .autoConnectSettings:
            return nil

        case .contentBlocker:
            return L10n.Settings.ContentBlocker.title

        case .applicationInformation:
            return L10n.Settings.ApplicationInformation.title

        case .reset:
            return L10n.Settings.Reset.title

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
            cell.textLabel?.text = L10n.Settings.Connection.VpnProtocol.title
            cell.detailTextLabel?.text = pendingPreferences.vpnType.vpnTypeDescription
            if !Flags.shared.enablesProtocolSelection {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }

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
            
            let dnsValue = pendingOpenVPNConfiguration.dnsServers
            for dns in DNSList.shared.dnsList {
                for (key, value) in dns {
                    if dnsValue == value {
                        cell.detailTextLabel?.text = DNSList.shared.descriptionForKey(key)
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
            cell.detailTextLabel?.text = pendingOpenVPNConfiguration.cipher.description
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
            cell.detailTextLabel?.text = pendingOpenVPNConfiguration.digest.description
            if !Flags.shared.enablesEncryptionSettings {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }

        case .encryptionHandshake:
            cell.textLabel?.text = L10n.Settings.Encryption.Handshake.title
            cell.detailTextLabel?.text = pendingOpenVPNConfiguration.handshake.description
            if !Flags.shared.enablesEncryptionSettings {
                cell.accessoryType = .none
                cell.selectionStyle = .none
            }

        case .automaticReconnection:
            cell.textLabel?.text = L10n.Settings.ApplicationSettings.KillSwitch.title
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchPersistent
            cell.selectionStyle = .none
            switchPersistent.isOn = pendingPreferences.isPersistentConnection

        case .mace:
            cell.textLabel?.text = L10n.Settings.ApplicationSettings.Mace.title
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchMACE
            cell.selectionStyle = .none
            switchMACE.isOn = pendingPreferences.mace
            
        case .contentBlockerState:
            cell.textLabel?.text = L10n.Settings.ContentBlocker.State.title
            cell.detailTextLabel?.text = nil
            if #available(iOS 10, *) {
                cell.accessoryView = switchContentBlocker
                cell.selectionStyle = .none
                switchContentBlocker.isOn = isContentBlockerEnabled
            }
            
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
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchConnectSiriShortcuts
            cell.selectionStyle = .none
            switchConnectSiriShortcuts.isOn = AppPreferences.shared.useConnectSiriShortcuts

        case .disconnectShortcut:
            cell.textLabel?.text = L10n.Siri.Shortcuts.Disconnect.Row.title
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchDisconnectSiriShortcuts
            cell.selectionStyle = .none
            switchDisconnectSiriShortcuts.isOn = AppPreferences.shared.useDisconnectSiriShortcuts

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
            let options: [String] = [
                IKEv2Profile.vpnType,
                PIATunnelProfile.vpnType,
                IPSecProfile.vpnType,
            ]
            controller = OptionsViewController()
            controller?.options = options
            controller?.selectedOption = pendingPreferences.vpnType
            
        case .vpnSocket:
            let options: [PIATunnelProvider.SocketType] = [
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
            let availablePorts = Client.providers.serverProvider.currentServersConfiguration.vpnPorts
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
                controller?.options = dnsList.compactMap {
                    if let first = $0.first {
                        return first.key
                    }
                    return nil
                }
            }
            
            if let options = controller?.options,
                !options.contains(DNSList.CUSTOM_DNS_KEY) {
                controller?.options.append(DNSList.CUSTOM_DNS_KEY)
            } else {
                for dns in DNSList.shared.dnsList {
                    for (key, value) in dns {
                        if key == DNSList.CUSTOM_DNS_KEY {
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
            
            controller?.selectedOption = pendingOpenVPNConfiguration.dnsServers
            
        case .encryptionCipher:
            guard Flags.shared.enablesEncryptionSettings else {
                break
            }
            let options: [PIATunnelProvider.Cipher] = [
                .aes128gcm,
                .aes256gcm,
                .aes128cbc,
                .aes256cbc
            ]
            controller = OptionsViewController()
            controller?.options = options.map { $0.rawValue }
            controller?.selectedOption = pendingOpenVPNConfiguration.cipher.rawValue

        case .encryptionDigest:
            guard Flags.shared.enablesEncryptionSettings else {
                break
            }
            guard !pendingOpenVPNConfiguration.isEncryptionGCM() else {
                break
            }
            let options: [PIATunnelProvider.Digest] = [
                .sha1,
                .sha256
            ]
            controller = OptionsViewController()
            controller?.options = options.map { $0.rawValue }
            controller?.selectedOption = pendingOpenVPNConfiguration.digest.rawValue

        case .encryptionHandshake:
            guard Flags.shared.enablesEncryptionSettings else {
                break
            }
            let options: [PIATunnelProvider.Handshake] = [
                .rsa2048,
                .rsa3072,
                .rsa4096,
                .ecc256r1,
                .ecc256k1,
                .ecc521r1
            ]
            controller = OptionsViewController()
            controller?.options = options.map { $0.rawValue }
            controller?.selectedOption = pendingOpenVPNConfiguration.handshake.rawValue
            
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
            let vpnType = option as? String
            cell.textLabel?.text = vpnType?.vpnTypeDescription
            
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
                cell.textLabel?.text = DNSList.shared.descriptionForKey(option)
                if option == DNSList.CUSTOM_DNS_KEY {
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
            cell.textLabel?.text = PIATunnelProvider.Cipher(rawValue: rawCipher)?.description

        case .encryptionDigest:
            let rawDigest = option as! String
            cell.textLabel?.text = PIATunnelProvider.Digest(rawValue: rawDigest)?.description

        case .encryptionHandshake:
            let rawHandshake = option as! String
            cell.textLabel?.text = PIATunnelProvider.Handshake(rawValue: rawHandshake)?.description

        default:
            break
        }
        
        cell.accessoryView = (isSelected ? imvSelectedOption : nil)

        if setting == .vpnDns,
            let option = option as? String {
            let dnsJoinedValue = pendingOpenVPNConfiguration.dnsServers.joined()
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
            let optSocketType = PIATunnelProvider.SocketType(rawValue: rawSocketType)

            let currentProtocols = pendingOpenVPNConfiguration.endpointProtocols
            var newProtocols: [PIATunnelProvider.EndpointProtocol] = []

            if let socketType = optSocketType {
                let ports = (socketType == .udp) ? serversCfg.vpnPorts.udp : serversCfg.vpnPorts.tcp
                if currentProtocols.count == 1, let currentPort = pendingOpenVPNConfiguration?.currentPort, ports.contains(currentPort) {
                    newProtocols.append(PIATunnelProvider.EndpointProtocol(socketType, currentPort, .pia))
                } else {
                    for port in ports {
                        newProtocols.append(PIATunnelProvider.EndpointProtocol(socketType, port, .pia))
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

            var newProtocols: [PIATunnelProvider.EndpointProtocol] = []
            if (port != SettingsViewController.AUTOMATIC_PORT) {
                guard let socketType = pendingOpenVPNSocketType else {
                    fatalError("Port cannot be set manually when socket type is automatic")
                }
                newProtocols.append(PIATunnelProvider.EndpointProtocol(socketType, port, .pia))
            } else {
                if (pendingOpenVPNSocketType == nil) {
                    newProtocols = AppConfiguration.VPN.piaAutomaticProtocols
                }
                else if (pendingOpenVPNSocketType == .udp) {
                    for port in serversCfg.vpnPorts.udp {
                        newProtocols.append(PIATunnelProvider.EndpointProtocol(.udp, port, .pia))
                    }
                }
                else if (pendingOpenVPNSocketType == .tcp) {
                    for port in serversCfg.vpnPorts.tcp {
                        newProtocols.append(PIATunnelProvider.EndpointProtocol(.tcp, port, .pia))
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
                            pendingOpenVPNConfiguration.dnsServers = value
                            break
                        }
                    }
                }
                
                if !isFound && option == DNSList.CUSTOM_DNS_KEY {
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
            pendingOpenVPNConfiguration.cipher = PIATunnelProvider.Cipher(rawValue: rawCipher)!

        case .encryptionDigest:
            let rawDigest = option as! String
            pendingOpenVPNConfiguration.digest = PIATunnelProvider.Digest(rawValue: rawDigest)!

        case .encryptionHandshake:
            let rawHandshake = option as! String
            pendingOpenVPNConfiguration.handshake = PIATunnelProvider.Handshake(rawValue: rawHandshake)!

        default:
            break
        }
        
        savePreferences()
        navigationController?.popViewController(animated: true)

    }
    
    private func savePreferences() {
        log.debug("OpenVPN endpoints: \(pendingOpenVPNConfiguration.endpointProtocols)")
        pendingPreferences.setVPNCustomConfiguration(pendingOpenVPNConfiguration.build(), for: pendingPreferences.vpnType)
        
        redisplaySettings()
        reportUpdatedPreferences()
    }
}

private extension PIATunnelProvider.ConfigurationBuilder {
//    var currentSocketType: PIATunnelProvider.SocketType {
//        guard let currentType = endpointProtocols.first?.socketType else {
//            fatalError("Zero current protocols")
//        }
//        return currentType
//    }

    var currentPort: UInt16? {
        guard endpointProtocols.count == 1 else {
            return nil
        }
        guard let port = endpointProtocols.first?.port else {
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
                pendingOpenVPNConfiguration.dnsServers = DNSList.shared.valueForKey(settingValue)
            }
        default:
            break
        }
        
        savePreferences()

    }
    
}

@available(iOS 12.0, *)
extension SettingsViewController: INUIAddVoiceShortcutViewControllerDelegate {

    func addVoiceShortcutViewController(
        _ controller: INUIAddVoiceShortcutViewController,
        didFinishWith voiceShortcut: INVoiceShortcut?,
        error: Error?
        ) {
        if let _ = error {
            let message = L10n.Siri.Shortcuts.Add.error
            let alert = Macros.alert(nil, message)
            alert.addCancelActionWithTitle(L10n.Global.cancel) {
                self.dismiss(animated: true, completion: nil)
            }
            self.present(alert, animated: true, completion: nil)
        } else {
            if let activityType = voiceShortcut?.shortcut.userActivity?.activityType {
                if activityType == AppConstants.SiriShortcuts.shortcutConnect {
                    AppPreferences.shared.useConnectSiriShortcuts = true
                    AppPreferences.shared.connectShortcut = voiceShortcut
                } else {
                    AppPreferences.shared.useDisconnectSiriShortcuts = true
                    AppPreferences.shared.disconnectShortcut = voiceShortcut
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }

    func addVoiceShortcutViewControllerDidCancel(
        _ controller: INUIAddVoiceShortcutViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}

@available(iOS 12.0, *)
extension SettingsViewController: INUIEditVoiceShortcutViewControllerDelegate {
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let error = error as? INIntentError {
            if let errorDescription = error.userInfo["NSDebugDescription"] as? String,
                let connectIdentifier = AppPreferences.shared.connectShortcut?.identifier.uuidString,
                errorDescription.contains(connectIdentifier) {
                AppPreferences.shared.useConnectSiriShortcuts = false
                AppPreferences.shared.connectShortcut = nil
            } else if let errorDescription = error.userInfo["NSDebugDescription"] as? String,
                let disconnectIdentifier = AppPreferences.shared.disconnectShortcut?.identifier.uuidString,
                errorDescription.contains(disconnectIdentifier) {
                AppPreferences.shared.useDisconnectSiriShortcuts = false
                AppPreferences.shared.disconnectShortcut = nil
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        if deletedVoiceShortcutIdentifier == AppPreferences.shared.connectShortcut?.identifier {
            AppPreferences.shared.useConnectSiriShortcuts = false
            AppPreferences.shared.connectShortcut = nil
        } else {
            AppPreferences.shared.useDisconnectSiriShortcuts = false
            AppPreferences.shared.disconnectShortcut = nil
        }
        dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        dismiss(animated: true, completion: nil)
    }
    

}
