//
//  GetStartedViewController.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 26/10/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
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
    @IBOutlet private weak var redeemButton: UIButton!
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
            if segue.identifier == StoryboardSegue.Welcome.restorePurchaseSegue.rawValue {
                if let vc = segue.destination as? RestoreSignupViewController {
                    vc.preset = preset
                }
            }
            return
        }
        
        vc.delegate = self.delegate
        vc.preset = self.preset

        switch segue.identifier  {
        case StoryboardSegue.Welcome.redeemGiftCardSegue.rawValue:
            vc.preset.pages = .redeem
        case StoryboardSegue.Welcome.purchaseVPNPlanSegue.rawValue:
            vc.preset.pages = .purchase
        case StoryboardSegue.Welcome.loginAccountSegue.rawValue:
            vc.preset.pages = .login
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
        redeemButton.setTitle(L10n.Welcome.Redeem.title,
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
        Theme.current.applyButtonLabelStyle(redeemButton)
        Theme.current.applyButtonLabelStyle(couldNotGetPlanButton)
    }

}
