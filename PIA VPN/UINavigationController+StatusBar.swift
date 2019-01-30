//
//  UINavigationController+StatusBar.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/25/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
