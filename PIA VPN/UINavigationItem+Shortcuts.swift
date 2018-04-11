//
//  UINavigationItem+Shortcuts.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/9/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

extension UINavigationItem {
    func setEmptyBackButton() {
        backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
    }
}
