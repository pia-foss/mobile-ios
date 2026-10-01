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

/// Logged-in window root that follows the horizontal size class while the window resizes.
///
/// - **regular**: the dashboard is the secondary column of an `AdaptiveSplitViewController`
///   with the menu as a sidebar.
/// - **compact**: the dashboard navigation controller is embedded directly and the menu is the
///   SideMenu drawer.
///
/// The root itself never changes, so modals presented over the dashboard survive the switch.
final class AdaptiveRootViewController: UIViewController {

    let dashboardNavigationController: UINavigationController

    private var split: AdaptiveSplitViewController?
    private var isRegular: Bool?

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

    // Isolated because the vertical bar API fails to compile for Catalyst on the 27.1 seed SDK.
    #if !targetEnvironment(macCatalyst)
        @available(iOS 27.1, *)
        override var childForPreferredVerticalBarBehavior: UIViewController? {
            contentViewController
        }
    #endif

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateLayout()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updateLayout(horizontalSizeClass: newCollection.horizontalSizeClass)
    }

    private func updateLayout(horizontalSizeClass: UIUserInterfaceSizeClass? = nil) {
        let sizeClass = horizontalSizeClass ?? traitCollection.horizontalSizeClass
        guard sizeClass != .unspecified else { return }
        let regular = sizeClass == .regular
        guard regular != isRegular else { return }
        isRegular = regular

        if regular {
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

    private func makeSplit() -> AdaptiveSplitViewController {
        let menuNav = StoryboardScene.Main.sideMenuNavigationController.instantiate()
        (menuNav.topViewController as? MenuViewController)?.delegate =
            dashboardNavigationController.viewControllers.first as? DashboardViewController

        let split = AdaptiveSplitViewController(style: .doubleColumn)
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
        #if !targetEnvironment(macCatalyst)
            if #available(iOS 27.1, *) {
                setNeedsUpdateOfVerticalBarConfiguration()
            }
        #endif
    }

    private func unembed(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
