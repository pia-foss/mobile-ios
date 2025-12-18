//
//  NetworkSettingsViewController.swift
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
import Popover
import PIALibrary
import TunnelKitCore
import TunnelKitOpenVPN
import PIAWireguard

protocol DNSSettingsDelegate: AnyObject {
    
    func updateSetting(_ setting: SettingSection, withValue value: Any?)
    
}

class NetworkSettingsViewController: PIABaseSettingsViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var controller: OptionsViewController?

    private static let DNS: String = "DNS"
    private lazy var imvSelectedOption = UIImageView(image: Asset.Images.accessorySelected.image)

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1.0
                
        tableView.delegate = self
        tableView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(reloadSettings), name: .PIASettingsHaveChanged, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Localizable.Settings.Section.network)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let customDNSSettingsVC = segue.destination as? CustomDNSSettingsViewController {
            customDNSSettingsVC.delegate = self
            customDNSSettingsVC.vpnType = pendingPreferences.vpnType == PIATunnelProfile.vpnType ? PIATunnelProfile.vpnType : PIAWGTunnelProfile.vpnType
            let ips = DNSList.shared.valueForKey(pendingPreferences.vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY)
            if !ips.isEmpty {
                customDNSSettingsVC.primaryDNSValue = ips.first
                if ips.count > 1 {
                    customDNSSettingsVC.secondaryDNSValue = ips.last
                }
            }
        } 
    }

    @objc private func reloadSettings() {
        tableView.reloadData()
        controller?.reload()
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        styleNavigationBarWithTitle(L10n.Localizable.Settings.Section.network)
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

extension NetworkSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NetworkSections.all().count
    }
    
    fileprivate func configure( _ cell: UITableViewCell, forSection section: NetworkSections) {
        switch section {
        case .dns:
            cell.textLabel?.text = Self.DNS
            
            var dnsValue = settingsDelegate.pendingOpenVPNConfiguration.dnsServers
            if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
                dnsValue = settingsDelegate.pendingWireguardVPNConfiguration.customDNSServers
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
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.setting, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil
        cell.selectionStyle = .default
        cell.detailTextLabel?.text = nil

        let section = NetworkSections.all()[indexPath.row]

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

    fileprivate func select(_ section: NetworkSections, inTableView tableView: UITableView, forIndexPath indexPath: IndexPath) {
        switch section {
        case .dns:
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
                                    title: L10n.Localizable.Global.edit,
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
                controller?.selectedOption = settingsDelegate.pendingWireguardVPNConfiguration.customDNSServers
            } else {
                controller?.selectedOption = settingsDelegate.pendingOpenVPNConfiguration.dnsServers
            }
            
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
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = NetworkSections.all()[indexPath.row]

        select(section, inTableView: tableView, forIndexPath: indexPath)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func edit(_ sender: Any?) {
        self.perform(segue: StoryboardSegue.Main.customDNSSegueIdentifier)
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionFooter(view)
    }

}



extension NetworkSettingsViewController: OptionsViewControllerDelegate {
    
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
    
    fileprivate func configure(_ option: AnyHashable, withCell cell: UITableViewCell, andSetting setting: NetworkSections) {
        switch setting {
        
        case .dns:
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
                
                var dnsJoinedValue = settingsDelegate.pendingOpenVPNConfiguration.dnsServers?.joined()
                if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
                    dnsJoinedValue = settingsDelegate.pendingWireguardVPNConfiguration.customDNSServers.joined()
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
            
        }
    }
    
    func optionsController(_ controller: OptionsViewController, renderOption option: AnyHashable, in cell: UITableViewCell, at row: Int, isSelected: Bool) {
        
        guard let setting = NetworkSections(rawValue: controller.tag) else {
            fatalError("Unhandled setting \(controller.tag)")
        }

        configure(option, withCell: cell, andSetting: setting)
        
        cell.accessoryView = (isSelected ? imvSelectedOption : nil)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Theme.current.palette.principalBackground
        cell.selectedBackgroundView = backgroundView

        Theme.current.applySecondaryBackground(cell)
        Theme.current.applyDetailTableCell(cell)
    }

    fileprivate func select(_ option: AnyHashable, withSetting setting: NetworkSections) {
        switch setting {
        
        case .dns:
            if let option = option as? String {
                var isFound = false
                
                for dns in DNSList.shared.dnsList {
                    for (key, value) in dns {
                        if key == option {
                            isFound = true
                            if pendingPreferences.vpnType == PIAWGTunnelProfile.vpnType {
                                settingsDelegate.pendingWireguardVPNConfiguration = PIAWireguardConfiguration(customDNSServers: value, packetSize: AppPreferences.shared.wireGuardUseSmallPackets ? AppConstants.WireGuardPacketSize.defaultPacketSize : AppConstants.WireGuardPacketSize.highPacketSize)
                            } else {
                                settingsDelegate.pendingOpenVPNConfiguration.dnsServers = value
                            }
                            break
                        }
                    }
                }
                
                if !isFound && option == (pendingPreferences.vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY) {
                    let alertController = Macros.alert(L10n.Localizable.Settings.Dns.Custom.dns,
                                                       L10n.Localizable.Settings.Dns.Alert.Create.message)
                    alertController.addActionWithTitle(L10n.Localizable.Global.ok) {
                        self.perform(segue: StoryboardSegue.Main.customDNSSegueIdentifier)
                    }
                    alertController.addCancelAction(L10n.Localizable.Global.cancel)
                    self.present(alertController,
                                 animated: true,
                                 completion: nil)
                }
                
            }
        }
    }
    
    func optionsController(_ controller: OptionsViewController, didSelectOption option: AnyHashable, at row: Int) {
        guard let setting = NetworkSections(rawValue: controller.tag) else {
            fatalError("Unhandled setting \(controller.tag)")
        }

        select(option, withSetting: setting)
        
        settingsDelegate.savePreferences()
        Macros.postNotification(.PIASettingsHaveChanged)
        navigationController?.popViewController(animated: true)

    }
    
}

extension NetworkSettingsViewController: DNSSettingsDelegate {
    
    func updateSetting(_ setting: SettingSection, withValue value: Any?) {
        settingsDelegate.updateSetting(setting, withValue: value)
    }
    
}
