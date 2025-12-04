//
//  AvailableTiles.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 25/11/2019.
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
import SwiftUI

class FeedbackTile: UIView, Tileable {
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal {
        didSet {
            statusUpdated()
        }
    }

    private let ratingManager: RatingManagerProtocol = RatingManager.shared
    private var hostingController: UIViewController?

    weak var viewController: UIViewController? {
        didSet {
            if let hostingController = hostingController, let viewController = viewController {
                viewController.addChild(hostingController)
                hostingController.view.frame = self.bounds
                viewController.didMove(toParent: viewController)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        if #available(iOS 15.0, *) {
            let feedbackView = FeedbackTileView()
            let hostingController = UIHostingController(rootView: feedbackView)

            guard let hostedView = hostingController.view else {
                return
            }

            self.hostingController = hostingController

            addSubview(hostedView)

            hostedView.translatesAutoresizingMaskIntoConstraints = false
            hostedView.backgroundColor = .clear

            NSLayoutConstraint.activate([
                hostedView.topAnchor.constraint(equalTo: topAnchor),
                hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
                hostedView.trailingAnchor.constraint(equalTo: trailingAnchor),
                hostedView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            self.view = hostedView
        }

        Theme.current.applyPrincipalBackground(self)
        self.accessibilityIdentifier = "FeedbackTile"
    }

    private func statusUpdated() {
    }
    
}
