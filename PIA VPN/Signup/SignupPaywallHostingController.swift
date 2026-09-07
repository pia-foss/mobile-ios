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
final class SignupPaywallHostingController: UIHostingController<SignupPaywallView> {

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
        hideNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideNavigationBarWhileTopmost()
    }
}

// MARK: - Bar-less screens

/// Shared by the two roots of the signup flow, both designed without a navigation bar.
extension UIViewController {
    /// Unanimated: on a pop back the flow's delegate has already animated the bar away, and animating
    /// it a second time shows the move twice.
    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    /// The same, asserted late: on iOS 15 every call that runs before the bar is laid out is lost.
    /// Only while this screen is on top, or it fights the bar a push just asked for.
    func hideNavigationBarWhileTopmost() {
        guard let navigationController,
            navigationController.topViewController === self,
            !navigationController.isNavigationBarHidden
        else { return }

        navigationController.setNavigationBarHidden(true, animated: false)
    }
}

/// The logged-out root and the cards screen are portrait-only on iPhone.
protocol PortraitLockedViewController: UIViewController {}

extension SignupPaywallHostingController: PortraitLockedViewController {}
