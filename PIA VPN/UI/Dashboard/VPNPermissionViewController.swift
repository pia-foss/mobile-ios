//
//  VPNPermissionViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 1/30/18.
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
import MessageUI

class VPNPermissionViewController: AutolayoutViewController {
    @IBOutlet private weak var imvPicture: UIImageView!

    @IBOutlet private weak var labelTitle: UILabel!

    @IBOutlet private weak var labelMessage: UILabel!

    @IBOutlet private weak var labelFooter: UILabel!

    @IBOutlet private weak var buttonSubmit: PIAButton!

    weak var dismissingViewController: UIViewController?

    override var navigationController: UINavigationController? {
        return super.navigationController ?? parent?.navigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Localizable.VpnPermission.title
        navigationItem.hidesBackButton = true
        self.view.accessibilityIdentifier = AccessibilityId.VPNPermission.screen

        imvPicture.image = Asset.Images.imageVpnAllow.image
        labelTitle.text = L10n.Localizable.VpnPermission.Body.title
        labelMessage.text = L10n.Localizable.VpnPermission.Body.subtitle(L10n.Localizable.Global.ok)
        labelFooter.text = L10n.Localizable.VpnPermission.Body.footer
        styleSubmitButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction private func submit() {
        let vpn = Client.providers.vpnProvider
        vpn.install(force: true, { (error) in
            guard (error == nil) else {
                self.alertRequiredPermission()
                return
            }
            self.dismissingViewController?.dismiss(animated: true) {
                //                vpn.connect(nil)
            }
        })
    }
    
    private func alertRequiredPermission() {
        var message = L10n.Localizable.VpnPermission.Disallow.Message.basic
        if MFMailComposeViewController.canSendMail() {
            message += "\n" + L10n.Localizable.VpnPermission.Disallow.Message.support
        }
        let alert = Macros.alert(L10n.Localizable.VpnPermission.title, message)
        if MFMailComposeViewController.canSendMail() {
            alert.addActionWithTitle(L10n.Localizable.VpnPermission.Disallow.contact) {
                self.contactCustomerSupport()
            }
        }
        alert.addCancelActionWithTitle(L10n.Localizable.Global.ok) {
            self.submit()
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func contactCustomerSupport() {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([AppConstants.Web.csEmail])
        vc.mailComposeDelegate = self
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyPrincipalBackground(viewContainer!)
        Theme.current.applySubtitle(labelMessage)
        Theme.current.applySubtitle(labelFooter)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
    }
    
    private func styleSubmitButton() {
        buttonSubmit.setRounded()
        buttonSubmit.style(style: TextStyle.Buttons.piaGreenButton)
        buttonSubmit.setTitle(L10n.Localizable.Global.ok.uppercased(),
                              for: [])
      buttonSubmit.accessibilityIdentifier = AccessibilityId.VPNPermission.submit
    }

}

extension VPNPermissionViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
