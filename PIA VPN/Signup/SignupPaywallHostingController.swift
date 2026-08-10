//
//  SignupPaywallHostingController.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
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

import PIAPaywall
import SwiftUI
import UIKit

/// Hosts the SwiftUI paywall inside UIKit.
///
/// Exists mainly so the rest of the app has a concrete type to recognise: the orientation lock and
/// the theme's status-bar rules used to switch on `GetStartedViewController`. They now match on
/// `SignupPaywallHosting` instead, so those call sites never learn about SwiftUI.
final class SignupPaywallHostingController: UIHostingController<SignupPaywallView>, SignupPaywallHosting {

    /// Set by the coordinator so the magic-link deep link can jump straight to the login screen.
    weak var paywallDelegate: SignupPaywallHostingDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        // `Theme`'s rules take an `AutolayoutViewController`, which this is not, so the style is
        // resolved here from the trait collection instead.
        traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Unanimated: on a pop back the delegate has already animated the bar away, and animating it
        // a second time shows the move twice.
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    /// The bar off the paywall, asserted late: on iOS 15 every earlier call runs before the bar is laid
    /// out and is lost. Only while the paywall is on top, or it fights the bar a push just asked for.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let navigationController,
            navigationController.topViewController === self,
            !navigationController.isNavigationBarHidden
        else { return }

        navigationController.setNavigationBarHidden(true, animated: false)
    }

    // MARK: SignupPaywallHosting

    func navigateToLogin() {
        paywallDelegate?.signupPaywallHostDidRequestLogin(self)
    }
}

/// What the app needs from whatever is currently showing the signup paywall.
///
/// A marker protocol rather than a concrete class check: `AppDelegate` and `Theme` previously
/// matched on `GetStartedViewController` by name, which silently stops working the moment the class
/// is replaced.
protocol SignupPaywallHosting: UIViewController {
    /// Pushes the login screen. Used by the magic-link deep link.
    func navigateToLogin()
}

protocol SignupPaywallHostingDelegate: AnyObject {
    func signupPaywallHostDidRequestLogin(_ host: SignupPaywallHosting)
}

/// The logged-out root and the cards screen are portrait-only on iPhone.
protocol PortraitLockedViewController: UIViewController {}

extension SignupPaywallHostingController: PortraitLockedViewController {}
