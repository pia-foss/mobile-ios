//
//  InvitesViewController.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 04/07/2019.
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

class InvitesViewController: AutolayoutViewController {

    @IBOutlet private weak var tableView: UITableView!
    var inviteInformation: InvitesInformation?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle(L10n.Friend.Referrals.Invites.Sent.title)
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        
        Theme.current.applyDividerToSeparator(tableView)
        Theme.current.applyPrincipalBackground(tableView)
        tableView.separatorColor = Theme.current.palette.appearance == .dark ?
            UIColor.piaGrey10 :
            UIColor.piaGrey2
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? InviteStatusViewController {
            viewController.inviteInformation = self.inviteInformation
            viewController.viewTitle = L10n.Friend.Referrals.Pending.Invites.title
            if segue.identifier == StoryboardSegue.Main.viewFriendReferralSignups.rawValue {
                viewController.inviteStatusViewMode = .signups
            }
        }
    }
    
    // MARK: Actions
    private func setupTableView() {
        let tableViewUtil = FriendReferralsTableViewUtil()
        tableViewUtil.registerCellForInvitesSentViewController(tableView)
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }

}

extension InvitesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let inviteInformation = self.inviteInformation,
            section == 1 {
            return L10n.Friend.Referrals.Invites.number(inviteInformation.invites.count).uppercased()
        }
        return nil
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return L10n.Friend.Referrals.Privacy.note
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionHeader(view)
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionFooter(view)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = InvitesSentCells.objectIdentifyBy(index: indexPath.section).identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath)
        if let inviteInformation = self.inviteInformation,
            let friendReferralCell = cell as? FriendReferralCell {
            if let cell = cell as? InvitesSentTableViewCell {
                cell.setupCell(withInviteInformation: inviteInformation, andRow: indexPath.row)
            } else {
                friendReferralCell.setupCell(withInviteInformation: inviteInformation)
            }
        }
        
        Theme.current.applySecondaryBackground(cell)
        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let inviteInformation = self.inviteInformation,
            indexPath.section == 1 {
            if indexPath.row == 0 {
                if inviteInformation.invites.filter({ !$0.rewarded }).count > 0 {
                    self.perform(segue: StoryboardSegue.Main.viewFriendReferralStatus)
                }
            } else {
                if inviteInformation.invites.filter({ $0.rewarded }).count > 0 {
                    self.perform(segue: StoryboardSegue.Main.viewFriendReferralSignups)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

