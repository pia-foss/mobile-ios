//
//  AdaptiveRootViewController.swift
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

import SideMenu
import UIKit

/// Logged-in window root that follows the window width while it resizes.
///
/// - **1000 pt and wider**: the dashboard is the secondary column of a split view with the menu as a
///   sidebar.
/// - **narrower**: the dashboard navigation controller is embedded directly and the menu is the
///   SideMenu drawer.
///
/// The root itself never changes, so modals presented over the dashboard survive the switch.
final class AdaptiveRootViewController: UIViewController {

    private let sidebarMinimumWidth: CGFloat = 1000

    let dashboardNavigationController: UINavigationController

    private var split: UISplitViewController?
    private var showsSidebar: Bool?

    init(dashboardNavigationController: UINavigationController) {
        self.dashboardNavigationController = dashboardNavigationController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var contentViewController: UIViewController? {
        children.first
    }

    override var childForStatusBarStyle: UIViewController? {
        contentViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        contentViewController
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateLayout(for: view.bounds.width)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateLayout(for: size.width)
    }

    private func updateLayout(for width: CGFloat) {
        guard width > 0 else { return }
        let sidebar = width >= sidebarMinimumWidth
        guard sidebar != showsSidebar else { return }
        showsSidebar = sidebar

        if sidebar {
            showSplit()
        } else {
            showDashboardOnly()
        }
    }

    private func showSplit() {
        if presentedViewController is SideMenuNavigationController {
            dismiss(animated: false)
        }
        if dashboardNavigationController.parent == self {
            unembed(dashboardNavigationController)
        }

        let split = self.split ?? makeSplit()
        self.split = split
        split.setViewController(dashboardNavigationController, for: .secondary)
        embed(split)
    }

    private func showDashboardOnly() {
        if let split, split.parent == self {
            unembed(split)
            split.setViewController(nil, for: .secondary)
        }
        embed(dashboardNavigationController)
    }

    private func makeSplit() -> UISplitViewController {
        let menuNav = StoryboardScene.Main.sideMenuNavigationController.instantiate()
        (menuNav.topViewController as? MenuViewController)?.delegate =
            dashboardNavigationController.viewControllers.first as? DashboardViewController

        let split = UISplitViewController(style: .doubleColumn)
        split.preferredDisplayMode = .oneBesideSecondary
        split.preferredSplitBehavior = .tile
        split.presentsWithGesture = true
        split.displayModeButtonVisibility = .never
        split.setViewController(menuNav, for: .primary)
        return split
    }

    private func embed(_ child: UIViewController) {
        guard child.parent != self else { return }
        addChild(child)
        child.view.frame = view.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(child.view)
        child.didMove(toParent: self)
        setNeedsStatusBarAppearanceUpdate()
    }

    private func unembed(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
