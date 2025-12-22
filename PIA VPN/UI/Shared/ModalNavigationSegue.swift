//
//  ModalNavigationSegue.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/25/17.
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

private let log = PIALogger.logger(for: ModalNavigationSegue.self)

class ModalNavigationSegue: UIStoryboardSegue {

    // XXX: dismissModal accessed via protocol is not exposed to Obj-C
    override func perform() {
        guard let modal = destination as? AutolayoutViewController else {
            log.error("Segue destination is not a ModalController")
            return
        }

        modal.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: modal,
            action: #selector(modal.dismissModal)
        )
        modal.navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Localizable.Global.close

        let nav = UINavigationController(rootViewController: modal)
        Theme.current.applyCustomNavigationBar(nav.navigationBar,
                                               withTintColor: nil,
                                               andBarTintColors: nil)
        
        if let coordinator = source.transitionCoordinator {
            coordinator.animate(alongsideTransition: { (context) in
                self.source.present(nav, animated: true, completion: nil)
            }, completion: nil)
        } else {
            nav.modalPresentationStyle = .overFullScreen
            source.present(nav, animated: true, completion: nil)
        }
    }
}
