//
//  WelcomePageViewController.swift
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

import PIALibrary
import UIKit

private let log = PIALogger.logger(for: WelcomePageViewController.self)

final class WelcomePageViewController: UIPageViewController {
    private var source = [UIViewController]()

    var config: Config!  // TODO: should be made private when segue navigation is removed

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let config else {
            log.error("Config not propagated")
            return
        }

        if config.pages.contains(.login) {
            let vc = LoginViewController.with(
                config: .init(
                    loginUsername: config.loginUsername,
                    loginPassword: config.loginPassword,
                    accountProvider: config.accountProvider,
                    completionDelegate: config.completionDelegate,
                ))
            source.append(vc)
        }
        if config.pages.contains(.purchase) {
            let vc = PurchaseViewController.with(
                config: .init(
                    isExpired: config.isExpired,
                    accountProvider: config.accountProvider,
                    completionDelegate: config.completionDelegate,
                ))
            source.append(vc)
        }
        if config.pages.contains(.restore) {
            let vc = RestoreSignupViewController.with(
                config: .init(
                    purchaseEmail: config.purchaseEmail,
                    accountProvider: config.accountProvider,
                    completionDelegate: config.completionDelegate,
                ))
            source.append(vc)
        }
        dataSource = self

        guard !source.isEmpty else {
            log.error("Source controllers are empty")
            return
        }
        let isSinglePage = (source.count == 1)
        guard isSinglePage || (config.pages == .all) else {
            log.error("Currently supports all pages or a single page, not a subset")
            return
        }

        setViewControllers([source.first!], direction: .forward, animated: false, completion: nil)

        if let scrollView = self.view.subviews.filter({
            $0.isKind(of: UIScrollView.self)
        }).first as? UIScrollView {
            scrollView.isScrollEnabled = false
        }

    }

    func show(page: Pages) {

        // XXX: quick temp solution for log2
        let index: Int
        switch page {
        case .login:
            index = 0

        case .purchase:
            index = 1

        case .restore:
            index = 3

        default:
            return
        }

        guard (index < source.count) else {
            log.error("Page \(index) beyond source controllers (\(source.count))")
            return
        }
        guard let vc = viewControllers?.first, let currentIndex = source.firstIndex(of: vc) else {
            log.error("No page displayed yet")
            return
        }
        let controller = source[index]
        let direction: UIPageViewController.NavigationDirection = (index > currentIndex) ? .forward : .reverse
        setViewControllers([controller], direction: direction, animated: true, completion: nil)
    }

    // MARK: Unwind

    @IBAction private func unwoundSignupFailure(segue: UIStoryboardSegue) {
    }

    // MARK: Size classes

    public override func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
        guard let window = view.window else {
            return super.traitCollection
        }
        let isLandscape = (window.bounds.size.width > window.bounds.size.height)
        let minHeight: CGFloat
        if childViewController is LoginViewController {
            minHeight = 568.0
        } else {
            minHeight = 667.0
        }
        if !Macros.isDevicePad && (isLandscape || (window.bounds.size.height < minHeight)) {
            return UITraitCollection(verticalSizeClass: .compact)
        } else {
            return UITraitCollection(verticalSizeClass: .regular)
        }
    }
}

extension WelcomePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = source.firstIndex(of: viewController) else {
            log.error("Cannot find view controller")
            return nil
        }
        if (index == 0) {
            return nil
        }
        return source[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = source.firstIndex(of: viewController) else {
            log.error("Cannot find view controller")
            return nil
        }
        if (index == source.count - 1) {
            return nil
        }
        return source[index + 1]
    }
}

extension WelcomePageViewController {
    struct Config {
        /// The login username.
        let loginUsername: String?

        /// The login password.
        let loginPassword: String?

        /// The purchase email address.
        let purchaseEmail: String?

        /// If `true`, shows variations based on the user expiration.
        let isExpired: Bool

        // TODO: use dependency injection
        let accountProvider: AccountProvider

        /// The `Pages` to display in the scroller.
        let pages: Pages

        weak var completionDelegate: WelcomeCompletionDelegate?
    }
}
