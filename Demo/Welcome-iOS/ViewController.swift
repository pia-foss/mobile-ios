//
//  ViewController.swift
//  Welcome-iOS
//
//  Created by Davide De Rosa on 10/20/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class ViewController: UIViewController, PIAWelcomeViewControllerDelegate {
    @IBOutlet private weak var buttonLogin: UIButton!
    
    @IBOutlet private weak var buttonLogout: UIButton!
    
    @IBOutlet private weak var labelUsername: UILabel!

    @IBOutlet private weak var labelPassword: UILabel!

    @IBOutlet private weak var labelExpiration: UILabel!

    @IBOutlet private weak var buttonExtend: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = Client.preferences.editable().reset()
        refresh(user: nil)
    }

    @IBAction private func logIn() {
        var preset = PIAWelcomeViewController.Preset()
        preset.pages = .all
        preset.allowsCancel = true
        preset.loginUsername = "p0000000"
        preset.loginPassword = "foobarbogus"
        preset.purchaseEmail = "foo@bar.com"
        
        let vc = PIAWelcomeViewController.with(preset: preset, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func logOut() {
        Client.providers.accountProvider.logout { (error) in
            self.refresh(user: nil)
        }
    }
    
    @IBAction private func extendSubscription() {
        let business = Client.providers.accountProvider
        
        business.purchase(plan: business.currentUser!.info!.plan) { (transaction, error) in
            business.renew(with: RenewRequest(transaction: transaction)) { (user, error) in
                guard let expirationDate = user?.info?.expirationDate else {
                    return
                }
                self.labelExpiration.text = expirationDate.description
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: PIAWelcomeViewControllerDelegate

    func welcomeController(_ welcomeController: PIAWelcomeViewController, didLoginWith user: UserAccount, topViewController: UIViewController) {
        let business = Client.providers.accountProvider
        refresh(user: user)

        print(">>> Logged in as: \(business.currentUser!)")
        dismiss(animated: true, completion: nil)
    }
    
    func welcomeController(_ welcomeController: PIAWelcomeViewController, didSignupWith user: UserAccount, topViewController: UIViewController) {
        let business = Client.providers.accountProvider

        print(">>> Signed up as: \(business.currentUser!)")
        business.logout(nil)
        dismiss(animated: true, completion: nil)
    }
    
    func welcomeControllerDidCancel(_ welcomeController: PIAWelcomeViewController) {
        dismiss(animated: true, completion: nil)

        print(">>> Cancelled")
    }
    
    private func refresh(user: UserAccount?) {
        let isLoggedIn: Bool
        if let user = user {
            isLoggedIn = true
            labelUsername.text = user.credentials.username
            labelPassword.text = user.credentials.password
            labelExpiration.text = user.info?.expirationDate.description
        } else {
            isLoggedIn = false
            labelUsername.text = "<username>"
            labelPassword.text = "<password>"
            labelExpiration.text = "<expiration>"
        }
        buttonLogin.isEnabled = !isLoggedIn
        buttonLogout.isEnabled = isLoggedIn
        buttonExtend.isEnabled = isLoggedIn
    }

    private func installVPN() {
//        #if !TARGET_IPHONE_SIMULATOR
//        PIAConnectionBusiness.sharedInstance().installProfile { (error) in
//            if let error = error {
//                log.error("Unable to install VPN profile: \(error)")
//                return
//            }
//            self.performSegue(withIdentifier: Segues.unwind, sender: nil)
//        }
//        #else
//        PIANotificationsPost(PIAVPNProfileDidInstallNotification, nil);
//        #endif
    }
}
