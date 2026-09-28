//
//  EscapeNavigationController.swift
//  PIA VPN
//
//  Created by Mario on 28/09/2026.
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import UIKit

final class EscapeNavigationController: UINavigationController {
    private var onEscape: (() -> Void)

    init(rootViewController: UIViewController, onEscape: @escaping () -> Void) {
        self.onEscape = onEscape
        super.init(rootViewController: rootViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var keyCommands: [UIKeyCommand]? {
        let escapeCommand = UIKeyCommand(
            input: UIKeyCommand.inputEscape,
            modifierFlags: [],
            action: #selector(escape)
        )
        return [escapeCommand]
    }

    @objc private func escape() {
        onEscape()
    }
}
