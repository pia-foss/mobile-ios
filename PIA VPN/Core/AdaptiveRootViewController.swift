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
/// - **1000 pt and wider**: the menu is a sidebar, drawn as a card floating over the full-width
///   dashboard. The system split view sidebar floats on iPadOS 26 but is flat on iPadOS 27 and Mac,
///   so the card keeps the same look everywhere.
/// - **narrower**: the dashboard navigation controller is embedded directly and the menu is the
///   SideMenu drawer.
///
/// The root itself never changes, so modals presented over the dashboard survive the switch.
final class AdaptiveRootViewController: UIViewController {

    private let sidebarMinimumWidth: CGFloat = 1000
    private let cardWidth: CGFloat = 320
    private let cardInset: CGFloat = 8
    private let cardCornerRadius: CGFloat = 20

    let dashboardNavigationController: UINavigationController

    private var isWide: Bool?

    private var menuCard: UIView?
    private var menuCardController: UIViewController?
    private var menuCardLeading: NSLayoutConstraint?
    private var isMenuCardHidden = false

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

    var showsSidebar: Bool {
        isWide == true
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let menuCard {
            menuCard.layer.shadowPath = UIBezierPath(roundedRect: menuCard.bounds, cornerRadius: cardCornerRadius).cgPath
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateLayout(for: size.width)
    }

    func toggleSidebar() {
        guard let menuCard else { return }
        isMenuCardHidden.toggle()
        // Hidden once off screen, so VoiceOver and keyboard focus can't reach the menu.
        menuCard.isHidden = false
        UIView.animate(
            withDuration: AppConfiguration.Animations.duration,
            animations: {
                self.updateMenuCardPosition()
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                menuCard.isHidden = self.isMenuCardHidden
            })
    }

    private func updateLayout(for width: CGFloat) {
        guard width > 0 else { return }
        let wide = width >= sidebarMinimumWidth
        guard wide != isWide else { return }
        isWide = wide

        if presentedViewController is SideMenuNavigationController {
            dismiss(animated: false)
        }
        if wide {
            showMenuCard()
        } else {
            showDashboardOnly()
        }
    }

    private func showDashboardOnly() {
        if let menuCardController {
            unembed(menuCardController)
        }
        menuCard?.removeFromSuperview()
        menuCard = nil
        menuCardController = nil
        menuCardLeading = nil
        dashboardNavigationController.additionalSafeAreaInsets = .zero
        embed(dashboardNavigationController)
    }

    private func showMenuCard() {
        embed(dashboardNavigationController)
        isMenuCardHidden = false

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.15
        card.layer.shadowRadius = 16
        card.layer.shadowOffset = .zero
        view.addSubview(card)

        let menu = makeMenuViewController()
        addChild(menu)
        menu.view.translatesAutoresizingMaskIntoConstraints = false
        menu.view.layer.cornerRadius = cardCornerRadius
        menu.view.layer.cornerCurve = .continuous
        menu.view.clipsToBounds = true
        card.addSubview(menu.view)
        menu.didMove(toParent: self)

        // On iPad the card starts below the status bar; the Mac title bar is hidden, so it hugs the top.
        #if targetEnvironment(macCatalyst)
            let cardTop = view.topAnchor
        #else
            let cardTop = view.safeAreaLayoutGuide.topAnchor
        #endif
        let leading = card.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        NSLayoutConstraint.activate([
            leading,
            card.topAnchor.constraint(equalTo: cardTop, constant: cardInset),
            card.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -cardInset),
            card.widthAnchor.constraint(equalToConstant: cardWidth),
            menu.view.topAnchor.constraint(equalTo: card.topAnchor),
            menu.view.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            menu.view.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            menu.view.trailingAnchor.constraint(equalTo: card.trailingAnchor)
        ])
        menuCard = card
        menuCardController = menu
        menuCardLeading = leading
        updateMenuCardPosition()
    }

    // The dashboard keeps the full width, so its header runs behind the card; the safe area keeps its content clear.
    private func updateMenuCardPosition() {
        menuCardLeading?.constant = isMenuCardHidden ? -(cardWidth + 2 * cardInset) : cardInset
        let inset = isMenuCardHidden ? 0 : cardWidth + cardInset
        let isRightToLeft = view.effectiveUserInterfaceLayoutDirection == .rightToLeft
        dashboardNavigationController.additionalSafeAreaInsets =
            isRightToLeft ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: inset) : UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)
    }

    // Taken out of the storyboard's SideMenuNavigationController, which on Mac hides the dashboard's bar items.
    private func makeMenuViewController() -> UIViewController {
        let menuNav = StoryboardScene.Main.sideMenuNavigationController.instantiate()
        let menu = menuNav.topViewController ?? UIViewController()
        menuNav.setViewControllers([], animated: false)
        (menu as? MenuViewController)?.delegate = dashboardNavigationController.viewControllers.first as? DashboardViewController
        return menu
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

extension UIViewController {
    var adaptiveRootViewController: AdaptiveRootViewController? {
        sequence(first: self, next: \.parent).lazy.compactMap { $0 as? AdaptiveRootViewController }.first
    }
}
