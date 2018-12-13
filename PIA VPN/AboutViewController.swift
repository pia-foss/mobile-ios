//
//  AboutViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
    
        let textApp = L10n.About.app
        labelIntro.text = "Copyright © \(AppConfiguration.About.copyright) \(AppConfiguration.About.companyName)\n\(textApp) \(Macros.versionFullString()!)"
        tableView.scrollsToTop = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        loadLicensesInBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        tableView.tableHeaderView = headerView
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
    }
    
    // MARK: Helpers
    
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
            
            guard let index = self.components.licenses.index(of: component) else {
                return
            }
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .none)
        }
    }
    
    // MARK: Restylable
    
    private func styleNavigationBar() {
        
        let currentStatus = Client.providers.vpnProvider.vpnStatus
        
        switch currentStatus {
        case .connected:
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.style(style: TextStyle.textStyle6)
            titleLabelView.text = L10n.Menu.Item.about
            Theme.current.applyCustomNavigationBar(navigationController!.navigationBar,
                                                   withTintColor: .white,
                                                   andBarTintColors: [UIColor.piaGreen,
                                                                      UIColor.piaGreenDark20])
            navigationItem.titleView = titleLabelView
            setNeedsStatusBarAppearanceUpdate()
            
        default:
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.style(style: Theme.current.palette.appearance == .dark ?
                TextStyle.textStyle6 :
                TextStyle.textStyle7)
            titleLabelView.text = L10n.Menu.Item.about
            Theme.current.applyCustomNavigationBar(navigationController!.navigationBar,
                                                   withTintColor: nil,
                                                   andBarTintColors: nil)
            navigationItem.titleView = titleLabelView
            setNeedsStatusBarAppearanceUpdate()
            
        }
    }

    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        tableView.separatorInset = UIEdgeInsetsMake(0, 30, 0, 0)
        styleNavigationBar()
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyLightBackground(view)
            Theme.current.applyLightBackground(viewContainer)
        }

        Theme.current.applySolidLightBackground(tableView)
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
