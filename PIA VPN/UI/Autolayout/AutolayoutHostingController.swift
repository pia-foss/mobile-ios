//
//  AutolayoutHostingController.swift
//  PIA VPN
//
//  Created by Mario on 30/03/2026.
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
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

public final class AutolayoutHostingController<Content: ViewWithTitle>: UIHostingController<Content>, ModalController, Restylable {

    public let onDismiss: () -> Void

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(rootView: Content, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(rootView: rootView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(viewShouldRestyle),
            name: .PIAThemeDidChange,
            object: nil
        )
        viewShouldRestyle()
    }

    public override var keyCommands: [UIKeyCommand]? {
        let escapeToClose = UIKeyCommand(
            input: UIKeyCommand.inputEscape,
            modifierFlags: [],
            action: #selector(dismissModal)
        )
        return [escapeToClose]
    }

    // MARK: ModalController

    @objc public func dismissModal() {
        dismissModal(completion: nil)
    }

    public func dismissModal(completion: (() -> Void)? = nil) {
        dismiss(animated: true) { [weak self] in
            completion?()
            self?.onDismiss()
        }
    }

    // MARK: Restylable

    @objc public func viewShouldRestyle() {
        AutolayoutViewController.styleNavigationBarWithTitle(rootView.navigationTitle, vc: self)
    }
}
