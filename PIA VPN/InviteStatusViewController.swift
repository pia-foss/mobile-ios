//
//  InviteStatusViewController.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 04/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class InviteStatusViewController: AutolayoutViewController {

    @IBOutlet private weak var tableView: UITableView!
    var viewTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle(viewTitle)
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

    // MARK: Actions
    private func setupTableView() {
        let tableViewUtil = FriendReferralsTableViewUtil()
        tableViewUtil.registerCellForInvitesStatusViewController(tableView)
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }

}

extension InviteStatusViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = InvitesStatusCells.objectIdentifyBy(index: indexPath.row).identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath)
        if let friendReferralCell = cell as? FriendReferralCell {
            friendReferralCell.setupCell()
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
    
}

