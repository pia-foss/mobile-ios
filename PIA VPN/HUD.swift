//
//  HUD.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 2/1/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary
import MBProgressHUD

class HUD {
    private let backend: MBProgressHUD
    
    init() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Can't locate front window")
        }
        
        backend = MBProgressHUD.showAdded(to: window, animated: true)
        backend.backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        backend.mode = .indeterminate
        backend.removeFromSuperViewOnHide = true

//        Theme.current.applyOverlay(hud.backgroundView)
//        Theme.current.applyOverlay(hud.bezelView)
    }

    func show() {
        backend.show(animated: true)
    }
    
    func hide() {
        backend.hide(animated: true)
    }
}
