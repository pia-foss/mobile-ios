//
//  PIAWelcomeViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/19/17.
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
import PIAUIKit

private let log = PIALogger.logger(for: PIAWelcomeViewController.self)

/**
 The welcome view controller is a graphic gateway to the PIA services.
 */
public class PIAWelcomeViewController: AutolayoutViewController, WelcomeCompletionDelegate, ConfigurationAccess, InAppAccess, BrandableNavigationBar {
 
    @IBOutlet private weak var buttonCancel: UIButton!

    var preset = Preset()
    
    var selectedPlanIndex: Int?
    
    var allPlans: [PurchasePlan]?
    
    private var pendingSignupRequest: SignupRequest?
    weak var delegate: PIAWelcomeViewControllerDelegate?
    
    /// It's `true` if the controller was created with `Preset.isEphemeral`.
    ///
    /// - Seealso: `Preset.isEphemeral`
    public var isEphemeral: Bool {
        return preset.isEphemeral
    }
    
    /**
     Creates a wrapped `PIAWelcomeViewController` ready for presentation.
     
     - Parameter preset: The optional `Preset` to configure this controller with
     - Parameter delegate: The `PIAWelcomeViewControllerDelegate` to handle raised events
     */
    public static func with(preset: Preset? = nil, delegate: PIAWelcomeViewControllerDelegate? = nil) -> UIViewController {
        let nav = StoryboardScene.Welcome.initialScene.instantiate()

        let vc = nav.topViewController as! PIAWelcomeViewController
        if let customPreset = preset {
            vc.preset = customPreset
        }
        vc.delegate = delegate
        return nav
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if preset.accountProvider.isLoggedIn {
            /// If the user is already logged in, this view controller should not have been presented.
            /// This can happen due to a race condition.
            /// We just dismiss it and it should trigger DashboardViewController's viewWillAppear,
            /// which will evaluate isLoggedIn as true and take another path.
            self.navigationController?.dismiss(animated: false)
            return
        }
        
        buttonCancel.isHidden = true
        
        #if os(iOS)
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(presentForceUpdate(notification:)), name: .__AppDidFetchForceUpdateFeatureFlag, object: nil)
        #endif

    }
    
    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !preset.openFromDashboard {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: Theme.current.palette.navigationBarBackIcon?.withRenderingMode(.alwaysOriginal),
                style: .plain,
                target: self,
                action: #selector(back(_:))
            )
            self.navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Welcome.Redeem.Accessibility.back
        } else {
            if preset.allowsCancel {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                    image: Asset.Images.iconClose.image.withRenderingMode(.alwaysOriginal),
                    style: .plain,
                    target: self,
                    action: #selector(cancelClicked(_:))
                )
                self.navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Ui.Global.cancel
            }
        }
    }
    
    /// :nodoc:
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tryRecoverSignupProcess()
    }
    
    // MARK: Actions
    @objc private func cancelClicked(_ sender: Any?) {
        delegate?.welcomeControllerDidCancel(self)
    }

    private func tryRecoverSignupProcess() {
        guard preset.shouldRecoverPendingSignup else {
            return
        }
        guard let request = preset.accountProvider.lastSignupRequest else {
            return
        }
        guard (pendingSignupRequest == nil) else {
            return
        }

        pendingSignupRequest = request
        perform(segue: StoryboardSegue.Welcome.signupViaRecoverSegue)
    }
    
    /// :nodoc:
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WelcomePageViewController {
            vc.preset = preset
            vc.completionDelegate = self
            vc.allPlans = allPlans
            vc.selectedPlanIndex = selectedPlanIndex
        }
        // recover pending signup
        else if (segue.identifier == StoryboardSegue.Welcome.signupViaRecoverSegue.rawValue) {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! SignupInProgressViewController
            
            guard let request = pendingSignupRequest else {
                log.error("pendingSignupRequest is not set in PIAWelcomeViewController")
                return
            }
            var metadata = SignupMetadata(email: request.email)
            metadata.title = L10n.Signup.InProgress.title
            metadata.bodySubtitle = L10n.Signup.InProgress.message
            vc.metadata = metadata
            vc.signupRequest = request
        }
    }
    
    // MARK: WelcomeCompletionDelegate
    
    func welcomeDidLogin(withUser user: UserAccount, topViewController: UIViewController) {
        delegate?.welcomeController(self, didLoginWith: user, topViewController: topViewController)
    }
    
    func welcomeDidSignup(withUser user: UserAccount, topViewController: UIViewController) {
        delegate?.welcomeController(self, didSignupWith: user, topViewController: topViewController)
    }

    // MARK: Notifications
    
    @objc func presentForceUpdate(notification: Notification) {
        #if !STAGING
        let forceUpdate = ForceUpdateViewController()
        forceUpdate.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async { [weak self] in
            var isOtherViewPresented = false
            if let presented = self?.presentedViewController {
                if !(presented is ForceUpdateViewController) {
                    isOtherViewPresented = true
                }
            }
            
            if isOtherViewPresented {
                self?.dismiss(animated: false, completion: {
                    self?.present(forceUpdate, animated: false)
                })
            } else {
                self?.present(forceUpdate, animated: false)
            }
        }
        #endif
    }
    
    // MARK: Restylable
    
    /// :nodoc:
    public override func viewShouldRestyle() {
        super.viewShouldRestyle()
        if !preset.isExpired {
            navigationItem.titleView = NavigationLogoView(logo: Theme.current.palette.logo)
        }
        else {
            navigationItem.title = L10n.Welcome.Upgrade.header
        }
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyNavigationBarStyle(to: self)
        Theme.current.applyCancelButton(buttonCancel, appearance: .dark)
    }
}

/// Receives events from a `PIAWelcomeViewController`.
public protocol PIAWelcomeViewControllerDelegate: AnyObject {

    /**
     Invoked after a successful login.
     
     - Parameter welcomeController: The delegating controller
     - Parameter user: The logged in `UserAccount`
     */
    func welcomeController(_ welcomeController: PIAWelcomeViewController, didLoginWith user: UserAccount, topViewController: UIViewController)

    /**
     Invoked after a successful signup.
     
     - Parameter welcomeController: The delegating controller
     - Parameter user: The signed up `UserAccount`
     */
    func welcomeController(_ welcomeController: PIAWelcomeViewController, didSignupWith user: UserAccount, topViewController: UIViewController)

    /**
     Invoked after a cancel.
     
     - Parameter welcomeController: The delegating controller
     */
    func welcomeControllerDidCancel(_ welcomeController: PIAWelcomeViewController)
}

public extension PIAWelcomeViewControllerDelegate {
    func welcomeControllerDidCancel(_ welcomeController: PIAWelcomeViewController) {}
}

protocol WelcomeChild: AnyObject {
    var preset: Preset? { get set }
    var omitsSiblingLink: Bool { get set }
    var completionDelegate: WelcomeCompletionDelegate? { get set }
}

protocol WelcomeCompletionDelegate: AnyObject {
    func welcomeDidLogin(withUser user: UserAccount, topViewController: UIViewController)
    func welcomeDidSignup(withUser user: UserAccount, topViewController: UIViewController)
}
