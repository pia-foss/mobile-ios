//
//  InvitesInformation.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 26/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation

/// The information associated with a `InvitesInformation`.
public struct InvitesInformation {
    
    public let totalInvitesSent: Int
    
    public let totalInvitesRewarded: Int

    public let totalFreeDaysGiven: Int

    public let invites: [Invites]
    
}
