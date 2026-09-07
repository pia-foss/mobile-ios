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

/// Hosts the SwiftUI paywall inside UIKit, and gives the orientation lock and the theme's
/// status-bar rules a concrete type to recognise.
final class SignupPaywallHostingController: UIHostingController<SignupPaywallView> {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        // `Theme`'s rules take an `AutolayoutViewController`, which this is not.
        traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideNavigationBarWhileTopmost()
    }
}

/// On iOS 15 the flow's `UINavigationControllerDelegate` hides the bar before it is laid out and the
/// call is lost, so the screens designed without one re-assert it here.
extension UIViewController {
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
