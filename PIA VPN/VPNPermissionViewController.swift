//
//  VPNPermissionViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 1/30/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary
import MessageUI

class VPNPermissionViewController: AutolayoutViewController {
    @IBOutlet private weak var imvPicture: UIImageView!

    @IBOutlet private weak var labelTitle: UILabel!

    @IBOutlet private weak var labelMessage: UILabel!

    @IBOutlet private weak var labelFooter: UILabel!

    @IBOutlet private weak var buttonSubmit: ActivityButton!

    weak var dismissingViewController: UIViewController?

    override var navigationController: UINavigationController? {
        return super.navigationController ?? parent?.navigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.VpnPermission.title
        navigationItem.hidesBackButton = true

        imvPicture.image = Asset.imageVpnAllow.image
        labelTitle.text = L10n.VpnPermission.Body.title
        labelMessage.text = L10n.VpnPermission.Body.subtitle(L10n.Global.ok)
        labelFooter.text = L10n.VpnPermission.Body.footer
        buttonSubmit.title = L10n.Global.ok
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction private func submit() {
        let vpn = Client.providers.vpnProvider
        vpn.install { (error) in
            guard (error == nil) else {
                self.alertRequiredPermission()
                return
            }
            self.dismissingViewController?.dismiss(animated: true) {
//                vpn.connect(nil)
            }
        }
    }
    
    private func alertRequiredPermission() {
        let alert = Macros.alert(L10n.VpnPermission.title, nil)
        var message = L10n.VpnPermission.Disallow.Message.basic
        alert.addDefaultAction(L10n.Global.ok) {
            self.submit()
        }
        if MFMailComposeViewController.canSendMail() {
            alert.addAction(UIAlertAction(title: L10n.VpnPermission.Disallow.contact, style: .default) { (action) in
                self.contactCustomerSupport()
            })
            message += "\n" + L10n.VpnPermission.Disallow.Message.support
        }
        alert.message = message
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
        
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applyBody1(labelMessage, appearance: .dark)
        Theme.current.applySmallInfo(labelFooter, appearance: .dark)
        Theme.current.applyActionButton(buttonSubmit)
    }
}

extension VPNPermissionViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
