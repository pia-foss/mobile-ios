//
//  PlatformSDKMigrationViewController.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import SwiftUI
import UIKit

final class PlatformSDKMigrationViewController: UIHostingController<PlatformSDKMigrationView> {

    init(onConfirm: @escaping () -> Void) {
        super.init(rootView: PlatformSDKMigrationView(onConfirm: onConfirm))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
