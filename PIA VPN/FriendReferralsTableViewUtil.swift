//
//  FriendReferralsTableViewUtil.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 03/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit

protocol FriendReferralCell {
    
    func setupCell()
    
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

class FriendReferralsTableViewUtil: NSObject {
    
    func registerCellsFor(_ tableView: UITableView) {
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
    
    
}
