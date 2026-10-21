//
//  SidebarRootViewController.swift
//  PIA VPN
//
//  Created by Mario on 16/10/26.
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

import UIKit

/// Gives the split a regular width on iPhone so it keeps its sidebar; its columns keep the real width.
final class SidebarRootViewController: UIViewController {
    let split: AdaptiveSplitViewController
    private let forcesRegularWidth: Bool

    init(split: AdaptiveSplitViewController) {
        self.split = split
        self.forcesRegularWidth = UIDevice.current.userInterfaceIdiom == .phone
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var childForStatusBarStyle: UIViewController? { split }
    override var childForStatusBarHidden: UIViewController? { split }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(split)
        split.view.frame = view.bounds
        split.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(split.view)
        split.didMove(toParent: self)

        guard forcesRegularWidth else { return }
        // iOS 15–16 otherwise sizes the overlay to nearly the full phone width.
        split.maximumPrimaryColumnWidth = 320
        if #available(iOS 17, *) {
            split.traitOverrides.horizontalSizeClass = .regular
            registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (self: Self, _) in
                self.applyColumnSizeClass()
            }
        } else {
            setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: .regular), forChild: split)
        }
        applyColumnSizeClass()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17), forcesRegularWidth {
            applyColumnSizeClass()
        }
    }

    private func applyColumnSizeClass() {
        let sizeClass = traitCollection.horizontalSizeClass
        for column in [UISplitViewController.Column.primary, .secondary] {
            guard let child = split.viewController(for: column) else { continue }
            if #available(iOS 17, *) {
                child.traitOverrides.horizontalSizeClass = sizeClass
            } else {
                split.setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: sizeClass), forChild: child)
            }
        }
    }
}
