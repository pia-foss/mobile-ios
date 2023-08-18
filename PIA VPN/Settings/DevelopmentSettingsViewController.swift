//
//  DevelopmentSettingsViewController.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 21/5/21.
//  Copyright © 2021 Private Internet Access, Inc.
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

import UIKit
import SwiftyBeaver
import PIALibrary
import SafariServices

private let log = SwiftyBeaver.self

class DevelopmentSettingsViewController: PIABaseSettingsViewController {
    
    private let dnsResolverURL = "google-analytics.com"

    @IBOutlet weak var tableView: UITableView!
    private lazy var switchEnvironment = UISwitch()
    private lazy var switchLeakProtectionFlag = UISwitch()
    private lazy var switchLeakProtectionNotificationsFlag = UISwitch()
    private var controller: OptionsViewController?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1.0
                
        tableView.delegate = self
        tableView.dataSource = self
        switchEnvironment.addTarget(self, action: #selector(toggleEnv(_:)), for: .valueChanged)
        
        addFeatureFlagsTogglesActions()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadSettings), name: .PIASettingsHaveChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle("Development")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let trustedNetworksVC = segue.destination as? TrustedNetworksViewController {
            trustedNetworksVC.persistentConnectionValue = pendingPreferences.isPersistentConnection
            trustedNetworksVC.vpnType = pendingPreferences.vpnType
        }
    }
    
    @objc private func reloadSettings() {
        tableView.reloadData()
    }
    
    @objc private func toggleEnv(_ sender: UISwitch) {
        if (Client.environment == .production) {
            AppPreferences.shared.appEnvironmentIsProduction = false
            Client.environment = .staging
        } else {
            AppPreferences.shared.appEnvironmentIsProduction = true
            Client.environment = .production
        }
        Client.resetWebServices()
        Client.providers.serverProvider.download(nil)
        reloadSettings()
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        styleNavigationBarWithTitle("Development")
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        Theme.current.applyPrincipalBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
        tableView.reloadData()
    }

}

extension DevelopmentSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DevelopmentSections.all().count
    }
    
    fileprivate func configure(_ cell: UITableViewCell, forSection section: DevelopmentSections) {
        switch section {
        case .resolveGoogleAdsDomain:
            cell.textLabel?.text = "Resolve google-analytics.com"
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
        case .environment:
            cell.textLabel?.text = "Staging"
            cell.detailTextLabel?.text = nil
            cell.accessoryView = switchEnvironment
            cell.selectionStyle = .none
            switchEnvironment.isOn = Client.environment == .staging
        case .customServers:
            cell.textLabel?.text = "Custom Servers"
            cell.detailTextLabel?.text = nil
        case .stagingVersion:
            cell.textLabel?.text = "Staging version"
            cell.detailTextLabel?.text = "\(AppPreferences.shared.stagingVersion)"
        case .deleteKeychain:
            cell.textLabel?.text = "Delete Keychain"
            cell.detailTextLabel?.text = nil
        case .crash:
            cell.textLabel?.text = "Crash"
            cell.detailTextLabel?.text = nil
        case .leakProtectionFlag:
          cell.textLabel?.text = "FF - Leak Protection"
          cell.detailTextLabel?.text = nil
          cell.accessoryView = switchLeakProtectionFlag
          cell.selectionStyle = .none
            switchLeakProtectionFlag.isOn = AppPreferences.shared.showLeakProtection
        case .leakProtectionNotificationsFlag:
          cell.textLabel?.text = "FF - Leak Protection Notifications"
          cell.detailTextLabel?.text = nil
          cell.accessoryView = switchLeakProtectionNotificationsFlag
          cell.selectionStyle = .none
            switchLeakProtectionNotificationsFlag.isOn = AppPreferences.shared.showLeakProtectionNotifications
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.setting, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil
        cell.selectionStyle = .default
        cell.detailTextLabel?.text = nil

        let section = DevelopmentSections.all()[indexPath.row]
        
        configure(cell, forSection: section)
        
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
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        let section = DevelopmentSections.all()[indexPath.row]
        switch section {
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = DevelopmentSections.all()[indexPath.row]

        switch section {
            case .resolveGoogleAdsDomain:
                resolveGoogleAdsDomain()

            case .customServers:
                self.perform(segue: StoryboardSegue.Main.customServerSegueIdentifier)

            case.stagingVersion:
                let options: [Int] = [
                    1,2,3,4,5
                ]
                controller = OptionsViewController()
                controller?.options = options.map { $0 }
                controller?.selectedOption = AppPreferences.shared.stagingVersion
                if let controller = controller {
                    guard let cell = tableView.cellForRow(at: indexPath) else {
                        fatalError("Cell not found at \(indexPath)")
                    }

                    controller.title = cell.textLabel?.text
                    controller.tag = section.rawValue
                    controller.delegate = self

                    parent?.navigationItem.setEmptyBackButton()
                    navigationController?.pushViewController(controller, animated: true)
                }

            case .crash:
                crashStagingApp()
        case .deleteKeychain:
                deleteKeychain()
            default: break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func crashStagingApp() {
        NSException(name: NSExceptionName(rawValue: "App Crash"), reason: "Crashing the staging app manually").raise()
    }
    
    private func deleteKeychain() {
        let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }
    
    private func resolveGoogleAdsDomain() {
        let resolver = DNSResolver(hostname: dnsResolverURL)
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
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionFooter(view)
    }

}

extension DevelopmentSettingsViewController: OptionsViewControllerDelegate {
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
        guard let setting = DevelopmentSections(rawValue: controller.tag) else {
            fatalError("Unhandled setting \(controller.tag)")
        }

        switch setting {
        case .stagingVersion:
            if let value = option as? Int {
                cell.textLabel?.text = "\(value)"
            }

        default:
            break
        }
                
        let backgroundView = UIView()
        backgroundView.backgroundColor = Theme.current.palette.principalBackground
        cell.selectedBackgroundView = backgroundView

        Theme.current.applySecondaryBackground(cell)
        Theme.current.applyDetailTableCell(cell)
    }

    func optionsController(_ controller: OptionsViewController, didSelectOption option: AnyHashable, at row: Int) {
        guard let setting = DevelopmentSections(rawValue: controller.tag) else {
            fatalError("Unhandled setting \(controller.tag)")
        }

        switch setting {
            
        case .stagingVersion:
            if let value = option as? Int {
                AppPreferences.shared.stagingVersion = value
                
                if let stagingUrl = AppConstants.Web.stagingEndpointURL {
                    let regexExpression = "staging-[0-9]"
                    let url = stagingUrl.absoluteString.replacingOccurrences(of: regexExpression, with: "staging-\(value)", options: .regularExpression)
                    Client.configuration.setBaseURL(url, for: .staging)
                    Client.resetWebServices()
                }

                settingsDelegate.refreshSettings()
                Macros.postNotification(.PIASettingsHaveChanged)

            }
        default:
            break
        }
        
        navigationController?.popViewController(animated: true)

    }
    
}


// MARK: - Feature Flags Toggles

extension DevelopmentSettingsViewController {
    @objc private func toggleLeakProtectionFlag(_ sender: UISwitch) {
        AppPreferences.shared.showLeakProtection = sender.isOn
    }
    
    @objc private func toggleLeakProtectionNotificationsFlag(_ sender: UISwitch) {
        AppPreferences.shared.showLeakProtectionNotifications = sender.isOn
    }
    
    private func addFeatureFlagsTogglesActions() {
        switchLeakProtectionFlag.addTarget(self, action: #selector(toggleLeakProtectionFlag(_:)), for: .valueChanged)
        switchLeakProtectionNotificationsFlag.addTarget(self, action: #selector(toggleLeakProtectionNotificationsFlag(_:)), for: .valueChanged)
        
        // Additional Feature Flags toggles actions here
    }
}
