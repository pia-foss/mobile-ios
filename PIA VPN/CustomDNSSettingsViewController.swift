//
//  CustomDNSSettingsViewController.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 24/10/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
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

    override func viewDidLoad() {
        
        self.title = L10n.Settings.Dns.Custom.dns
        configureTextfields()
        configureNavigationBar()

        super.viewDidLoad()
        
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
            DNSList.shared.addNewServerWithName(DNSList.CUSTOM_DNS_KEY,
                                                andIPs: ips)
            self.delegate?.updateSetting(Setting.vpnDns,
                                         withValue: DNSList.CUSTOM_DNS_KEY)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    @objc private func clear(_ sender: Any?) {
        let alertController = Macros.alert(L10n.Settings.Dns.Alert.Clear.title,
                                           L10n.Settings.Dns.Alert.Clear.message)
        
        let saveAction = UIAlertAction(title: L10n.Global.ok, style: UIAlertActionStyle.default, handler: { alert -> Void in
            if let firstKey = DNSList.shared.firstKey() {
                DNSList.shared.removeServer(name: DNSList.CUSTOM_DNS_KEY)
                self.delegate?.updateSetting(Setting.vpnDns,
                                             withValue: firstKey)
            }
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        let cancelAction = UIAlertAction(title: L10n.Global.cancel, style: UIAlertActionStyle.default,
                                         handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController,
                     animated: true,
                     completion: nil)

    }

    // MARK: Restylable
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        if let viewContainer = viewContainer {
            Theme.current.applyLightBackground(viewContainer)
        }

        for label in [labelPrimaryDNS!, labelSecondaryDNS!] {
            Theme.current.applyLabel(label, appearance: .dark)
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: L10n.Global.update,
            style: .plain,
            target: self,
            action: #selector(update(_:))
        )
    }
    
    private func configureTextfields() {
        labelPrimaryDNS.text = L10n.Settings.Dns.primaryDNS
        labelSecondaryDNS.text = L10n.Settings.Dns.secondaryDNS
        textPrimaryDNS.placeholder = L10n.Global.required
        textSecondaryDNS.placeholder = L10n.Global.optional
        textPrimaryDNS.keyboardType = .decimalPad
        textSecondaryDNS.keyboardType = .decimalPad
        
        textPrimaryDNS.text = primaryDNSValue
        textSecondaryDNS.text = secondaryDNSValue
    }
    
    /// Validates if the primary DNS is not empty and is valid and if the secondary DNS is valid
    private func isValidForm() -> Bool {
        
        if (textPrimaryDNS.text == nil ||
            (textPrimaryDNS.text != nil && textPrimaryDNS.text!.isEmpty)) {
            let alert = Macros.alert(L10n.Settings.Dns.Custom.dns,
                                     L10n.Settings.Dns.Validation.Primary.mandatory)
            alert.addCancelAction(L10n.Global.ok)
            self.present(alert,
                         animated: true,
                         completion: nil)
            return false
        }
        
        if let primaryDNS = textPrimaryDNS.text,
            !isValidAddress(primaryDNS) {
            let alert = Macros.alert(L10n.Settings.Dns.Validation.Primary.invalid,
                                     nil)
            alert.addCancelAction(L10n.Global.ok)
            self.present(alert,
                         animated: true,
                         completion: nil)
            return false
        }
        
        if let secondaryDNS = textSecondaryDNS.text,
            !secondaryDNS.isEmpty,
            !isValidAddress(secondaryDNS) {
            let alert = Macros.alert(L10n.Settings.Dns.Validation.Secondary.invalid,
                                     nil)
            alert.addCancelAction(L10n.Global.ok)
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
