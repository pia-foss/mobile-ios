//
//  GlossInvitesInformation.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 26/07/2019.
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

import Foundation
import Gloss

class GlossInvitesInformation: GlossParser {
    
    let parsed: InvitesInformation
    
    required init?(json: JSON) {
        
        let totalInvites: Int = "total_invites_sent" <~~ json ?? 0
        let totalRewarded: Int = "total_invites_rewarded" <~~ json ?? 0
        let totalDays: Int = "total_free_days_given" <~~ json ?? 0
        
        guard let uniqueReferralLink: String = "unique_referral_link" <~~ json else {
            return nil
        }
        
        var invites : [Invites] = []
        
        if let inviteJSON = json["invites"] as? [JSON] {
            
            for invite in inviteJSON {
                
                guard let rewarded: Bool = "rewarded" <~~ invite else {
                    return nil
                }
                guard let accepted: Bool = "accepted" <~~ invite else {
                    return nil
                }
                guard let obfuscatedEmail: String = "obfuscated_email" <~~ invite else {
                    return nil
                }
                guard let gracePeriodRemaining: String = "grace_period_remaining" <~~ invite else {
                    return nil
                }
             
                invites.append(Invites(rewarded: rewarded,
                                       accepted: accepted,
                                       obfuscatedEmail: obfuscatedEmail,
                                       gracePeriodRemaining: gracePeriodRemaining))
            }

        }
        
        parsed = InvitesInformation(totalInvitesSent: totalInvites,
                                    totalInvitesRewarded: totalRewarded,
                                    totalFreeDaysGiven: totalDays,
                                    uniqueReferralLink: uniqueReferralLink,
                                    invites: invites)
        
    }
}
