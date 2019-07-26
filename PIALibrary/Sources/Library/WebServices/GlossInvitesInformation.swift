//
//  GlossInvitesInformation.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 26/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation
import Gloss

class GlossInvitesInformation: GlossParser {
    
    let parsed: InvitesInformation
    
    required init?(json: JSON) {
        
        let totalInvites: Int = "total_invites_sent" <~~ json ?? 0
        let totalRewarded: Int = "total_invites_rewarded" <~~ json ?? 0
        let totalDays: Int = "total_free_days_given" <~~ json ?? 0
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
                                    invites: invites)
        
    }
}
