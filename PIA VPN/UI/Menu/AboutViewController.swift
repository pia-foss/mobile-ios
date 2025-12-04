//
//  AboutViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
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

import UIKit
import PIALibrary

class AboutViewController: AutolayoutViewController {
    private struct Cells {
        static let notice = "NoticeCell"

        static let license = "LicenseCell"
    }

    @IBOutlet private weak var labelIntro: UILabel!

    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var components: Components = {
        guard let plist = AppConstants.About.componentsPath else {
            fatalError("No components plist found for About")
        }
        return Components(plist)
    }()

    private var licenseByComponentName: [String: String] = [:]
    
    private var expandedComponentIndex: Int?

    private var expandedComponentHeight: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let textApp = L10n.Localizable.About.app
        labelIntro.text = "Copyright © \(AppConfiguration.About.copyright) \(AppConfiguration.About.companyName)\n\(textApp) \(Macros.versionFullString()!)"
        tableView.scrollsToTop = true
        
        if UserInterface.isIpad {
            let nc = NotificationCenter.default
            nc.addObserver(self, selector: #selector(viewHasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        loadLicensesInBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Localizable.Menu.Item.about)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        tableView.tableHeaderView = headerView
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Helpers
    
    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(L10n.Localizable.Menu.Item.settings)
    }
    
    private func loadLicensesInBackground() {
        for component in components.licenses {
            performSelector(inBackground: #selector(fetchLicenseWithComponent(_:)), with: component)
        }
    }
    
    @objc private func fetchLicenseWithComponent(_ componentBridge: Any) {
        let component = componentBridge as! LicenseComponent
        let license = (try? String(contentsOf: component.licenseURL, encoding: .ascii)) ?? ""
        
        DispatchQueue.main.async {
            self.licenseByComponentName[component.name] = license
            
            guard let index = self.components.licenses.firstIndex(of: component) else {
                return
            }
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .none)
        }
    }
    
    // MARK: Restylable

    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        Theme.current.applyDividerToSeparator(tableView)
        styleNavigationBarWithTitle(L10n.Localizable.Menu.Item.about)
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }

        Theme.current.applyPrincipalBackground(tableView)
        Theme.current.applySubtitle(labelIntro)
    }
}

extension AboutViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return components.notices.count
            
        case 1:
            return components.licenses.count
            
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let component = components.notices[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.notice, for: indexPath) as! AboutNoticeCell
            cell.fill(withComponent: component)
            return cell

        case 1:
            let component = components.licenses[indexPath.row]
            let license = licenseByComponentName[component.name]
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.license, for: indexPath) as! AboutLicenseCell
            cell.delegate = self
            cell.fill(withComponent: component, license: license, isExpanded: (indexPath.row == expandedComponentIndex))
            return cell

        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 110.0
            
        case 1:
            if (indexPath.row == expandedComponentIndex) {
                assert(expandedComponentHeight > 0.0)
                return min(view.bounds.size.height, expandedComponentHeight)
            } else {
                return tableView.rowHeight
            }
            
        default:
            fatalError()
        }
    }
}

extension AboutViewController: AboutLicenseCellDelegate {
    func aboutCell(_ cell: AboutLicenseCell, shouldExpand license: String?) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let oldExpandedComponentIndex = expandedComponentIndex
        expandedComponentIndex = indexPath.row
        expandedComponentHeight = cell.heightThatFits
        
        var outdatedIndexPaths: [IndexPath] = []
        if let old = oldExpandedComponentIndex {
            outdatedIndexPaths.append(IndexPath(row: old, section: 1))
        }
        outdatedIndexPaths.append(IndexPath(row: expandedComponentIndex!, section: 1))
        tableView.reloadRows(at: outdatedIndexPaths, with: .automatic)
    }
    
    func aboutCell(_ cell: AboutLicenseCell, shouldShrink license: String?) {
        guard let old = expandedComponentIndex else {
            return
        }
        expandedComponentIndex = nil
        tableView.reloadRows(at: [IndexPath(row: old, section: 1)], with: .automatic)
    }
}
