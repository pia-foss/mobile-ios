//
//  AutolayoutHostingController.swift
//  PIA VPN
//
//  Created by Mario on 30/03/2026.
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import PIALibrary
import PIASwiftUI
import PIAUIKit
import SwiftUI

public final class AutolayoutHostingController<Content: ViewWithTitle>: UIHostingController<Content>, ModalController, Restylable {

    deinit {
        NotificationCenter.default.removeObserver(self)
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

    // MARK: ModalController

    public func dismissModal() {
        dismissModal(completion: nil)
    }

    public func dismissModal(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }

    // MARK: Restylable

    @objc public func viewShouldRestyle() {
        AutolayoutViewController.styleNavigationBarWithTitle(rootView.navigationTitle, vc: self)
    }
}
