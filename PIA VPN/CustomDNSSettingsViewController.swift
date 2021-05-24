//
//  CustomDNSSettingsViewController.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 24/10/2018.
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

import Foundation
import PIALibrary

class CustomDNSSettingsViewController: AutolayoutViewController {
    
    var primaryDNSValue: String?
    var secondaryDNSValue: String?
    
    @IBOutlet private weak var labelPrimaryDNS: UILabel!
    @IBOutlet private weak var textPrimaryDNS: BorderedTextField!
    @IBOutlet private weak var labelSecondaryDNS: UILabel!
    @IBOutlet private weak var textSecondaryDNS: BorderedTextField!

    weak var delegate: SettingsViewControllerDelegate?
    var vpnType: String?

    override func viewDidLoad() {
        
        self.title = L10n.Settings.Dns.Custom.dns
        configureTextfields()
        configureNavigationBar()

        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Settings.Dns.Custom.dns)
    }
    
    // MARK: Actions
    @objc private func update(_ sender: Any?) {
        if isValidForm() {
            var ips: [String] = []
            if let primaryDNS = textPrimaryDNS.text {
                ips.append(primaryDNS)
            }
            if let secondaryDNS = textSecondaryDNS.text,
                !secondaryDNS.isEmpty {
                ips.append(secondaryDNS)
            }
            DNSList.shared.addNewServerWithName((vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY),
                                                andIPs: ips)
            self.delegate?.updateSetting(NetworkSections.dns,
                                         withValue: (vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY))
            Macros.postNotification(.PIASettingsHaveChanged)
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc private func clear(_ sender: Any?) {
        let alertController = Macros.alert(L10n.Settings.Dns.Alert.Clear.title,
                                           L10n.Settings.Dns.Alert.Clear.message)
        
        alertController.addActionWithTitle(L10n.Global.ok) {
            if let firstKey = DNSList.shared.firstKey() {
                DNSList.shared.removeServer(name: (self.vpnType == PIATunnelProfile.vpnType ? DNSList.CUSTOM_OPENVPN_DNS_KEY : DNSList.CUSTOM_WIREGUARD_DNS_KEY))
                self.delegate?.updateSetting(NetworkSections.dns,
                                             withValue: firstKey)
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addCancelAction(L10n.Global.cancel)
        
        self.present(alertController,
                     animated: true,
                     completion: nil)

    }

    // MARK: Restylable
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle(L10n.Settings.Dns.Custom.dns)
        
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }

        for label in [labelPrimaryDNS!, labelSecondaryDNS!] {
            Theme.current.applySubtitle(label)
        }
        
        Theme.current.applyInput(textPrimaryDNS)
        Theme.current.applyInput(textSecondaryDNS)
        
    }
    
    // MARK: Private
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: L10n.Global.clear,
            style: .plain,
            target: self,
            action: #selector(clear(_:))
        )
        navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Global.clear

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: L10n.Global.update,
            style: .plain,
            target: self,
            action: #selector(update(_:))
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = L10n.Global.update
    }
    
    private func configureTextfields() {
        labelPrimaryDNS.text = L10n.Settings.Dns.primaryDNS
        labelSecondaryDNS.text = L10n.Settings.Dns.secondaryDNS
        textPrimaryDNS.placeholder = L10n.Global.required
        textSecondaryDNS.placeholder = L10n.Global.optional
        textPrimaryDNS.keyboardType = .numbersAndPunctuation
        textSecondaryDNS.keyboardType = .numbersAndPunctuation
        
        textPrimaryDNS.text = primaryDNSValue
        textSecondaryDNS.text = secondaryDNSValue
    }
    
    /// Validates if the primary DNS is not empty and is valid and if the secondary DNS is valid
    private func isValidForm() -> Bool {
        
        if (textPrimaryDNS.text == nil ||
            (textPrimaryDNS.text != nil && textPrimaryDNS.text!.isEmpty)) {
            let alert = Macros.alert(L10n.Settings.Dns.Custom.dns,
                                     L10n.Settings.Dns.Validation.Primary.mandatory)
            alert.addDefaultAction(L10n.Global.ok)
            self.present(alert,
                         animated: true,
                         completion: nil)
            return false
        }
        
        if let primaryDNS = textPrimaryDNS.text,
            !isValidAddress(primaryDNS) {
            let alert = Macros.alert(L10n.Settings.Dns.Custom.dns,
                                     L10n.Settings.Dns.Validation.Primary.invalid)
            alert.addDefaultAction(L10n.Global.ok)
            self.present(alert,
                         animated: true,
                         completion: nil)
            return false
        }
        
        if let secondaryDNS = textSecondaryDNS.text,
            !secondaryDNS.isEmpty,
            !isValidAddress(secondaryDNS) {
            let alert = Macros.alert(L10n.Settings.Dns.Custom.dns,
                                     L10n.Settings.Dns.Validation.Secondary.invalid)
            alert.addDefaultAction(L10n.Global.ok)
            self.present(alert,
                         animated: true,
                         completion: nil)
            return false
        }
        
        return true
    }
    
    ///Validates the address
    /// - Parameters:
    ///   - ip: The ip to validate
    /// - Returns:
    ///   - Bool: The result of the validation
    private func isValidAddress(_ ip: String) -> Bool {
        let validIP = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
        if ((ip.count == 0) || (ip.range(of: validIP,
                                         options: .regularExpression) == nil)) {
            return false
        }
        return true
    }

}
