//
//  RootCoordinator.swift
//  PIA VPN
//
//  Created by Mario on 15/05/26.
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
import UIKit

/// Owns the app's `window.rootViewController` and switches between the logged-in main UI
/// (`UISplitViewController` on iPad, `UINavigationController(Dashboard)` on iPhone) and the
/// logged-out login UI (`GetStartedViewController`).
final class RootCoordinator: NSObject {
    enum AppRoot {
        case login
        case main
    }

    static let shared = RootCoordinator()

    private weak var window: UIWindow?
    private(set) var currentRoot: AppRoot?
    private(set) var splitViewController: UISplitViewController?
    private(set) var dashboardNavigationController: UINavigationController?

    var dashboard: DashboardViewController? {
        dashboardNavigationController?.viewControllers.first as? DashboardViewController
    }

    func install(in window: UIWindow) {
        self.window = window
        // The storyboard auto-loads a UINavigationController(Dashboard) as the initial root.
        // Reuse it when we end up in `.main` so we don't double-instantiate.
        if let initialNav = window.rootViewController as? UINavigationController,
            initialNav.viewControllers.first is DashboardViewController
        {
            self.dashboardNavigationController = initialNav
        }
        let initialState: AppRoot = Client.providers.accountProvider.isLoggedIn ? .main : .login
        setRoot(initialState)
    }

    func setRoot(_ root: AppRoot) {
        guard let window else { return }
        currentRoot = root

        let newRoot: UIViewController
        switch root {
        case .login:
            splitViewController = nil
            dashboardNavigationController = nil
            newRoot = makeLoginRoot()
        case .main:
            newRoot = makeMainRoot()
        }

        window.rootViewController = newRoot
        window.makeKeyAndVisible()
    }

    private func makeMainRoot() -> UIViewController {
        let dashboardNav = dashboardNavigationController ?? Self.instantiateDashboardNavigationController()
        self.dashboardNavigationController = dashboardNav

        if UserInterface.isIpad {
            let menuNav = StoryboardScene.Main.sideMenuNavigationController.instantiate()
            let split = UISplitViewController(style: .doubleColumn)
            split.preferredDisplayMode = .oneBesideSecondary
            split.preferredSplitBehavior = .tile
            split.presentsWithGesture = true
            split.setViewController(menuNav, for: .primary)
            split.setViewController(dashboardNav, for: .secondary)
            splitViewController = split
            return split
        } else {
            splitViewController = nil
            return dashboardNav
        }
    }

    private func makeLoginRoot() -> UIViewController {
        var preset = AppConfiguration.Welcome.defaultPreset()
        preset.shouldRecoverPendingSignup = false
        if !TransientState.didRetryPendingSignup {
            TransientState.didRetryPendingSignup = true
        }
        let config = GetStartedViewController.Config(
            accountProvider: preset.accountProvider,
        )
        let vc = GetStartedViewController.with(config: config, delegate: self)
        return vc ?? UIViewController()
    }

    private static func instantiateDashboardNavigationController() -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let nav = storyboard.instantiateViewController(withIdentifier: "DashboardNavigationController") as? UINavigationController else {
            fatalError("Storyboard 'Main' is missing the 'DashboardNavigationController' identifier")
        }
        return nav
    }

    /// Returns the topmost view controller suitable for presenting alerts / modals,
    /// drilling through nav, split, and presented chains. Works for both iPad split view
    /// and the iPhone single-nav layout.
    func topPresentedViewController() -> UIViewController? {
        guard let root = window?.rootViewController else { return nil }
        return Self.deepestTop(of: root)
    }

    private static func deepestTop(of vc: UIViewController) -> UIViewController {
        if let presented = vc.presentedViewController {
            return deepestTop(of: presented)
        }
        if let nav = vc as? UINavigationController, let top = nav.visibleViewController {
            return deepestTop(of: top)
        }
        if let split = vc as? UISplitViewController {
            if let secondary = split.viewController(for: .secondary) {
                return deepestTop(of: secondary)
            }
            if let last = split.viewControllers.last {
                return deepestTop(of: last)
            }
        }
        return vc
    }
}

// MARK: - PIAWelcomeViewControllerDelegate (used when login is the root, i.e. iPad logged-out)

extension RootCoordinator: PIAWelcomeViewControllerDelegate {
    func welcomeController(_ welcomeController: PIAWelcomeViewController, didLoginWith user: UserAccount, topViewController: UIViewController) {
        handleAuthenticationSuccess()
    }

    func welcomeController(_ welcomeController: PIAWelcomeViewController, didSignupWith user: UserAccount, topViewController: UIViewController) {
        if welcomeController.preset.isEphemeral {
            Client.providers.accountProvider.currentUser = user
        }
        handleAuthenticationSuccess()
    }

    func welcomeControllerDidCancel(_ welcomeController: PIAWelcomeViewController) {
        // No-op: cancel inside login-as-root has nothing to dismiss back to.
    }

    private func handleAuthenticationSuccess() {
        setRoot(.main)
        // After the root swap settles, present the VPN permission modal over Dashboard so
        // the user grants permission before reaching the dashboard tiles.
        DispatchQueue.main.async { [weak self] in
            guard let self, let dashboard = self.dashboard else { return }
            let permissionVC = StoryboardScene.Main.vpnPermissionViewController.instantiate()
            permissionVC.dismissingViewController = dashboard
            let nav = UINavigationController(rootViewController: permissionVC)
            nav.modalPresentationStyle = .fullScreen
            dashboard.present(nav, animated: true)
        }
    }
}
