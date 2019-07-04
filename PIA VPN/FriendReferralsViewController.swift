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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(shareUniqueCode), name: .ShareFriendReferralCode, object: nil)

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

    // MARK: Actions
    private func setupTableView() {
        let tableViewUtil = FriendReferralsTableViewUtil()
        tableViewUtil.registerCellsFor(tableView)
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    @objc private func shareUniqueCode() {
        if let link = NSURL(string: "http://www.google.com") {
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
        if let friendReferralCell = cell as? FriendReferralCell {
            friendReferralCell.setupCell()
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
