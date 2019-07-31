//
//  FriendReferralsViewController.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 03/07/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class FriendReferralsViewController: AutolayoutViewController {

    @IBOutlet private weak var tableView: UITableView!
    private let numberOfSections = 3
    private let numberOfRowsInSection = 1
    private var inviteInformation: InvitesInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(shareUniqueCode), name: .ShareFriendReferralCode, object: nil)
        nc.addObserver(self, selector: #selector(refreshInviteInformation), name: .FriendInvitationSent, object: nil)

        refreshInviteInformation()

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle("Refer a Friend")
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        
        Theme.current.applyPrincipalBackground(tableView)
        tableView.separatorColor = Theme.current.palette.appearance == .dark ?
            UIColor.piaGrey10 :
            UIColor.piaGrey2

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? InvitesViewController {
            viewController.inviteInformation = self.inviteInformation
        }
    }

    // MARK: Actions
    private func setupTableView() {
        let tableViewUtil = FriendReferralsTableViewUtil()
        tableViewUtil.registerCellsForFriendReferralsViewController(tableView)
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    @objc private func refreshInviteInformation() {
        self.showLoadingAnimation()
        Client.providers.accountProvider.invitesInformation({ [weak self] (inviteInfo, error) in
            if let weakSelf = self {
                weakSelf.hideLoadingAnimation()
                weakSelf.inviteInformation = inviteInfo
                weakSelf.tableView.reloadData()
            }
        })
    }
    
    @objc private func shareUniqueCode() {
        if let shareUrl = self.inviteInformation?.uniqueReferralLink,
            let link = NSURL(string: shareUrl) {
            let activityVC = UIActivityViewController(activityItems: [link],
                                                      applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }

}

extension FriendReferralsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = FriendReferralCells.objectIdentifyBy(index: indexPath.section).identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath)
        if let inviteInformation = self.inviteInformation,
            let friendReferralCell = cell as? FriendReferralCell {
            friendReferralCell.setupCell(withInviteInformation: inviteInformation)
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
        if indexPath.section == 0 {
            self.perform(segue: StoryboardSegue.Main.showReferralInvites)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
