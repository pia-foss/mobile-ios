//
//  SubscriptionTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 14/01/2019.
//  Copyright © 2020 Private Internet Access Inc.
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
        Theme.current.applyPrincipalBackground(self)
        displayAccountInformation()
    }
    
    @objc private func displayAccountInformation() {
        let currentUser = Client.providers.accountProvider.currentUser
        
        if let userInfo = currentUser?.info {
            if userInfo.isExpired {
                self.subscriptionValue.text = L10n.Account.ExpiryDate.expired
            } else {
                var value = L10n.Account.ExpiryDate.information(userInfo.humanReadableExpirationDate())
                if let days = daysLeftFromAccountInfo(userInfo) {
                    let daysLeft = L10n.Tiles.Subscription.Days.left(days)
                    let plan = planDescriptionFromPlan(userInfo.plan)
                    if plan != "" {
                        value = plan + " " + daysLeft
                    }
                }
                self.subscriptionValue.text = value
            }
            Theme.current.makeSmallLabelToStandOut(self.subscriptionValue,
                                                   withTextToStandOut: planDescriptionFromPlan(userInfo.plan))
        }
        
    }

    private func planDescriptionFromPlan(_ plan: Plan) -> String {
        switch plan {
        case .trial: return L10n.Tiles.Subscription.trial
        case .monthly: return L10n.Tiles.Subscription.monthly
        case .yearly: return L10n.Tiles.Subscription.yearly
        default: return ""
        }
    }
    
    private func daysLeftFromAccountInfo(_ userInfo: AccountInfo) -> Int? {
        if let days = userInfo.dateComponentsBeforeExpiration.day {
            return days +
            1 + //today
            1 //last day
        }
        return nil
    }
}
