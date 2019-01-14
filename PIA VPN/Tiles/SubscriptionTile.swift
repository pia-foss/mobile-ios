//
//  SubscriptionTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 14/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class SubscriptionTile: UIView, Tileable  {
    
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal
    
    @IBOutlet private weak var subscriptionTitle: UILabel!
    @IBOutlet private weak var subscriptionValue: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
        self.setupView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(displayAccountInformation), name: .PIAAccountDidRefresh, object: nil)

        viewShouldRestyle()
        self.subscriptionTitle.text = L10n.Tiles.Subscription.title.uppercased()
        displayAccountInformation()
    }
    
    @objc private func viewShouldRestyle() {
        subscriptionTitle.style(style: TextStyle.textStyle21)
        Theme.current.applySubtitle(subscriptionValue)
        Theme.current.applySolidLightBackground(self)
    }
    
    @objc private func displayAccountInformation() {
        let currentUser = Client.providers.accountProvider.currentUser
        
        if let userInfo = currentUser?.info {
            if userInfo.isExpired {
                self.subscriptionValue.text = L10n.Account.ExpiryDate.expired
            } else {
                self.subscriptionValue.text = L10n.Account.ExpiryDate.information(userInfo.humanReadableExpirationDate())
            }
            Theme.current.makeSmallLabelToStandOut(self.subscriptionValue,
                                                   withTextToStandOut: userInfo.humanReadableExpirationDate())
        }
        
    }

}
