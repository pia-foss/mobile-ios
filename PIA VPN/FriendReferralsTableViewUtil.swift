//
//  FriendReferralsTableViewUtil.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 03/07/2019.
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

protocol FriendReferralCell {
    
    func setupCell(withInviteInformation inviteInformation: InvitesInformation)
    
}

enum FriendReferralCells: Int, EnumsBuilder {
    
    case invitesSent = 0
    case invite
    case share
    
    var identifier: String {
        switch self {
        case .invitesSent: return "InvitesSentCell"
        case .invite: return "InviteFriendCell"
        case .share: return "ShareInvitationCell"
        }
    }
    
    var className: String {
        switch self {
        case .invitesSent: return "InvitesSentTableViewCell"
        case .invite: return "InviteFriendTableViewCell"
        case .share: return "ShareInvitationTableViewCell"
        }
    }
}

enum InvitesSentCells: Int, EnumsBuilder {
    
    case daysAcquired = 0
    case invitesSent
    
    var identifier: String {
        switch self {
        case .daysAcquired: return "DaysAcquiredCell"
        case .invitesSent: return "InvitesSentCell"
        }
    }
    
    var className: String {
        switch self {
        case .daysAcquired: return "DaysAcquiredTableViewCell"
        case .invitesSent: return "InvitesSentTableViewCell"
        }
    }
}

enum InvitesStatusCells: Int, EnumsBuilder {
    
    case statusCell = 0
    
    var identifier: String {
        switch self {
        case .statusCell: return "InviteStatusCell"
        }
    }
    
    var className: String {
        switch self {
        case .statusCell: return "InviteStatusTableViewCell"
        }
    }
}

class FriendReferralsTableViewUtil: NSObject {
    
    func registerCellsForFriendReferralsViewController(_ tableView: UITableView) {
        tableView.register(UINib(nibName: FriendReferralCells.invitesSent.className,
                                 bundle: nil),
                           forCellReuseIdentifier: FriendReferralCells.invitesSent.identifier)
        tableView.register(UINib(nibName: FriendReferralCells.invite.className,
                                 bundle: nil),
                           forCellReuseIdentifier: FriendReferralCells.invite.identifier)
        tableView.register(UINib(nibName: FriendReferralCells.share.className,
                                 bundle: nil),
                           forCellReuseIdentifier: FriendReferralCells.share.identifier)
        tableView.backgroundColor = .clear
    }
    
    func registerCellForInvitesSentViewController(_ tableView: UITableView) {
        tableView.register(UINib(nibName: InvitesSentCells.invitesSent.className,
                                 bundle: nil),
                           forCellReuseIdentifier: InvitesSentCells.invitesSent.identifier)
        tableView.register(UINib(nibName: InvitesSentCells.daysAcquired.className,
                                 bundle: nil),
                           forCellReuseIdentifier: InvitesSentCells.daysAcquired.identifier)
    }
    
    func registerCellForInvitesStatusViewController(_ tableView: UITableView) {
        tableView.register(UINib(nibName: InvitesStatusCells.statusCell.className,
                                 bundle: nil),
                           forCellReuseIdentifier: InvitesStatusCells.statusCell.identifier)
    }
}
