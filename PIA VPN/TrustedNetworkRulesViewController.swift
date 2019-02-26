//
//  TrustedNetworkRulesViewController.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 18/02/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class TrustedNetworkRulesViewController: AutolayoutViewController {

    @IBOutlet private weak var tableView: UITableView!
    private lazy var switchTrusted = UISwitch()

    private enum Sections: Int, EnumsBuilder {
        case trusted = 0
    }

    private struct Cells {
        static let rules = "RulesCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = L10n.Settings.Hotspothelper.Rules.title
        self.switchTrusted.addTarget(self, action: #selector(toggleTrusted(_:)), for: .valueChanged)
        configureTableView()
    }
    
    // MARK: Private Methods
    private func configureTableView() {
        if #available(iOS 11, *) {
            tableView.sectionFooterHeight = UITableViewAutomaticDimension
            tableView.estimatedSectionFooterHeight = 1.0
        }
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle(L10n.Settings.Hotspothelper.Rules.title)
        
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        Theme.current.applyPrincipalBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
    }
    
    @objc private func toggleTrusted(_ sender: UISwitch) {
        let preferences = Client.preferences.editable()
        preferences.disconnectOnTrusted = sender.isOn
        preferences.commit()
    }

}

extension TrustedNetworkRulesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.countCases()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections.objectIdentifyBy(index: section) {
        case .trusted:
            return L10n.Settings.Trusted.Networks.Sections.trusted.uppercased()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Sections.objectIdentifyBy(index: section) {
        case .trusted:
            return L10n.Settings.Trusted.Networks.Sections.Trusted.Rule.description
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.rules, for: indexPath)
        cell.selectionStyle = .default
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.isUserInteractionEnabled = true
        cell.imageView?.image = Asset.iconWifi.image.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = Theme.current.palette.textColor(forRelevance: 3, appearance: .dark)
        
        switch Sections.objectIdentifyBy(index: indexPath.section) {
        case .trusted:
            cell.imageView?.image = nil
            cell.textLabel?.text = L10n.Settings.Trusted.Networks.Sections.Trusted.Rule.action
            cell.accessoryView = switchTrusted
            cell.selectionStyle = .none
            switchTrusted.isOn = Client.preferences.disconnectOnTrusted
            
        }
        
        cell.textLabel?.backgroundColor = .clear
        Theme.current.applySecondaryBackground(cell)
        Theme.current.applyDetailTableCell(cell)
        if let textLabel = cell.textLabel {
            Theme.current.applySettingsCellTitle(textLabel,
                                                 appearance: .dark)
            textLabel.backgroundColor = .clear
        }
        
        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionHeader(view)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionFooter(view)
    }
    
}
