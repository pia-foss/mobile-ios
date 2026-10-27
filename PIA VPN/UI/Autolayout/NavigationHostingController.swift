//
//  NavigationHostingController.swift
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
import PIASwiftUI
import PIAUIKit
import SwiftUI

/// `onFinish` runs once, on pop or dealloc.
final class NavigationHostingController<Content: ViewWithTitle>: UIHostingController<Content>, Restylable {
    private var onFinish: (() -> Void)?

    init(rootView: Content, onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        super.init(rootView: rootView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        finish()
    }

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
        if parent == nil {
            finish()
        }
    }

    private func finish() {
        let onFinish = onFinish
        self.onFinish = nil
        onFinish?()
    }

    // MARK: Restylable

    @objc func viewShouldRestyle() {
        AutolayoutViewController.styleNavigationBarWithTitle(rootView.navigationTitle, vc: self)
    }
}
