//
//  GetStartedViewController.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 26/10/2018.
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

public class GetStartedViewController: AutolayoutViewController, ConfigurationAccess {

    @IBOutlet private weak var viewHeaderBackground: UIView!
    @IBOutlet private weak var viewHeader: UIView!
    @IBOutlet private weak var labelVersion: UILabel!
    @IBOutlet private weak var constraintHeaderHeight: NSLayoutConstraint!
    @IBOutlet private weak var imvLogo: UIImageView!
    @IBOutlet private weak var centeredMap: UIImageView!
    
    @IBOutlet private weak var loginButton: PIAButton!
    @IBOutlet private weak var buyButton: PIAButton!
    @IBOutlet private weak var couldNotGetPlanButton: UIButton!

    var preset = Preset()
    private weak var delegate: PIAWelcomeViewControllerDelegate?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func viewDidLoad() {

        imvLogo.image = Theme.current.palette.logo
        centeredMap.image = Theme.current.palette.logo
        labelVersion.text = Macros.localizedVersionFullString()
        view.backgroundColor = UIColor.piaGrey1

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(recoverAccount), name: .PIARecoverAccount, object: nil)
        
        self.styleButtons()
        
        super.viewDidLoad()

    }
    
    /**
     Creates a wrapped `GetStartedViewController` ready for presentation.
     
     - Parameter preset: The optional `Preset` to configure this controller with
     - Parameter delegate: The `PIAWelcomeViewControllerDelegate` to handle raised events
     */
    public static func with(preset: Preset? = nil, delegate: PIAWelcomeViewControllerDelegate? = nil) -> UIViewController {
        let nav = StoryboardScene.Welcome.initialScene.instantiate()
        let vc = nav.topViewController as! GetStartedViewController
        if let customPreset = preset {
            vc.preset = customPreset
        }
        vc.delegate = delegate
        return nav
    }
    
    public static func withPurchase(preset: Preset? = nil, delegate: PIAWelcomeViewControllerDelegate? = nil) -> UIViewController {
        if let vc = StoryboardScene.Welcome.storyboard.instantiateViewController(withIdentifier: "PIAWelcomeViewController") as? PIAWelcomeViewController {
            if let customPreset = preset {
                vc.preset = customPreset
            }
            vc.delegate = delegate
            let navigationController = UINavigationController(rootViewController: vc)
            return navigationController
        }
        return UIViewController()
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let vc = segue.destination as? PIAWelcomeViewController else {
            return
        }
        
        vc.delegate = self.delegate
        vc.preset = self.preset

        switch segue.identifier  {
        case StoryboardSegue.Welcome.purchaseVPNPlanSegue.rawValue:
            vc.preset.pages = .purchase
        case StoryboardSegue.Welcome.loginAccountSegue.rawValue:
            vc.preset.pages = .login
        case StoryboardSegue.Welcome.restorePurchaseSegue.rawValue:
            vc.preset.pages = .restore
        default:
            break
        }
        
    }

    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func styleButtons() {
        loginButton.setRounded()
        buyButton.setRounded()
        
        buyButton.style(style: TextStyle.Buttons.piaGreenButton)
        loginButton.style(style: TextStyle.Buttons.piaPlainTextButton)
        
        loginButton.setTitle(L10n.Welcome.Login.submit.uppercased(),
                             for: [])
        buyButton.setTitle(L10n.Welcome.Getstarted.Buttons.buyaccount.uppercased(),
                           for: [])
        couldNotGetPlanButton.setTitle(L10n.Welcome.Login.Restore.button,
                                       for: [])
    }
    
    // MARK: Restylable
    
    /// :nodoc:
    public override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyPrincipalBackground(viewHeaderBackground)
        Theme.current.applyPrincipalBackground(viewHeader)
        Theme.current.applyVersionNumberStyle(labelVersion)
        Theme.current.applyCenteredMap(centeredMap)
        Theme.current.applyTransparentButton(loginButton,
                                             withSize: 1.0)
        Theme.current.applyButtonLabelStyle(couldNotGetPlanButton)
    }

    // MARK: Notification event
    @objc private func recoverAccount() {
        self.performSegue(withIdentifier: StoryboardSegue.Welcome.restorePurchaseSegue.rawValue,
                          sender: nil)
    }
}
