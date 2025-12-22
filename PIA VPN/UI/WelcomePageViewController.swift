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

import UIKit
import PIALibrary

private let log = PIALogger.logger(for: WelcomePageViewController.self)

class WelcomePageViewController: UIPageViewController {
    private var source = [UIViewController]()
    
    var preset: Preset?
    
    var selectedPlanIndex: Int?
    
    var allPlans: [PurchasePlan]?
    
    weak var completionDelegate: WelcomeCompletionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let preset = self.preset else {
            log.error("Preset not propagated")
            return
        }

        if preset.pages.contains(.login) {
            let vc = StoryboardScene.Welcome.loginViewController.instantiate()
            source.append(vc)
        }
        if preset.pages.contains(.purchase) {
            let vc = StoryboardScene.Welcome.purchaseViewController.instantiate()
            source.append(vc)
        }
        if preset.pages.contains(.restore) {
            let vc = StoryboardScene.Welcome.restoreSignupViewController.instantiate()
            source.append(vc)
        }
        dataSource = self

        guard !source.isEmpty else {
            log.error("Source controllers are empty")
            return
        }
        let isSinglePage = (source.count == 1)
        guard isSinglePage || (preset.pages == .all) else {
            log.error("Currently supports all pages or a single page, not a subset")
            return
        }

        for vc in source {
            guard let child = vc as? WelcomeChild else {
                log.error("Source element must be a WelcomeChild")
                return
            }
            child.preset = preset
            child.omitsSiblingLink = !isSinglePage
            child.completionDelegate = completionDelegate
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
        guard let currentIndex = source.index(of: viewControllers!.first!) else {
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
        if let _ = childViewController as? LoginViewController {
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
        guard let index = source.index(of: viewController) else {
            log.error("Cannot find view controller")
            return nil
        }
        if (index == 0) {
            return nil
        }
        return source[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = source.index(of: viewController) else {
            log.error("Cannot find view controller")
            return nil
        }
        if (index == source.count - 1) {
            return nil
        }
        return source[index + 1]
    }
}
