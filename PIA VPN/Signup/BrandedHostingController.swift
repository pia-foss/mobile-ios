//
//  BrandedHostingController.swift
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

import PIALibrary
import PIAUIKit
import SwiftUI
import UIKit

/// Hosts a SwiftUI sign-in screen under the branded logo bar the signup flow uses.
final class BrandedHostingController<Content: View>: UIHostingController<Content>, Restylable {
    /// Runs once, when the screen leaves the navigation stack.
    var onFinish: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(viewShouldRestyle),
            name: .PIAThemeDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewShouldRestyle()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        guard parent == nil else { return }
        let onFinish = onFinish
        self.onFinish = nil
        onFinish?()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    // MARK: Restylable

    @objc func viewShouldRestyle() {
        navigationItem.titleView = NavigationLogoView(logo: Theme.current.palette.logo)
        if let navigationBar = navigationController?.navigationBar {
            Theme.current.applyLightBrandLogoNavigationBar(navigationBar)
        }
        setNeedsStatusBarAppearanceUpdate()
    }
}
