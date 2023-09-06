//
//  GeneralSettingsViewController.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 17/5/21.
//  Copyright © 2021 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import UIKit
import SwiftyBeaver
import PIALibrary

class GeneralSettingsViewController: PIABaseSettingsViewController {
    
    private lazy var switchGeoServers = UISwitch()
    private lazy var switchInAppMessages = UISwitch()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1.0
        
        switchGeoServers.addTarget(self, action: #selector(toggleGEOServers(_:)), for: .valueChanged)
        switchInAppMessages.addTarget(self, action: #selector(toggleShowServiceMessages(_:)), for: .valueChanged)
        
        tableView.delegate = self
        tableView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(reloadSettings), name: .PIASettingsHaveChanged, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Settings.Section.general)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.tableView.reloadData()
    }

    @objc private func toggleShowServiceMessages(_ sender: UISwitch) {
        AppPreferences.shared.showServiceMessages = sender.isOn
    }
    
    @objc private func toggleGEOServers(_ sender: UISwitch) {
        AppPreferences.shared.showGeoServers = sender.isOn
        tableView.reloadData()
        NotificationCenter.default.post(name: .PIADaemonsDidPingServers,
            object: self,
            userInfo: nil)
    }

    @objc private func reloadSettings() {
        tableView.reloadData()
    }
    
    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        styleNavigationBarWithTitle(L10n.Settings.Section.general)
        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        Theme.current.applyPrincipalBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
        reloadSettings()
        
    }

}

extension GeneralSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GeneralSections.all().count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Cells.footer) {
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.style(style: TextStyle.textStyle21)
            cell.backgroundColor = .clear
            cell.textLabel?.text =  L10n.Settings.Reset.footer
            return cell
        }
        return nil

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.setting, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil
        cell.selectionStyle = .default
        cell.detailTextLabel?.text = nil

        let section = GeneralSections.all()[indexPath.row]
        
        cell.textLabel?.text = section.localizedTitleMessage()

        switch section {
            case .showServiceCommunicationMessages:
                cell.accessoryView = switchInAppMessages
                cell.selectionStyle = .none
                switchInAppMessages.isOn = AppPreferences.shared.showServiceMessages //invert the boolean as the title has change to Show messages instead of Stop messages

            case .showGeoRegions:
                cell.textLabel?.numberOfLines = 0
                cell.accessoryView = switchGeoServers
                cell.selectionStyle = .none
                switchGeoServers.isOn = AppPreferences.shared.showGeoServers

            default:
                break
        }

        Theme.current.applySecondaryBackground(cell)
        if let textLabel = cell.textLabel {
            Theme.current.applySettingsCellTitle(textLabel,
                                                 appearance: .dark)
            textLabel.backgroundColor = .clear
        }
        if let detailLabel = cell.detailTextLabel {
            Theme.current.applySubtitle(detailLabel)
            detailLabel.backgroundColor = .clear
        }
        
        let backgroundView = UIView()
        Theme.current.applyPrincipalBackground(backgroundView)
        cell.selectedBackgroundView = backgroundView

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = GeneralSections.all()[indexPath.row]
        
        switch section {
            
        case .resetSettings:
            settingsDelegate.resetToDefaultSettings()
            
        case .connectSiri:
            SiriShortcutsManager.shared.presentConnectShortcut(inViewController: self)

        case .disconnectSiri:
            SiriShortcutsManager.shared.presentDisconnectShortcut(inViewController: self)

        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        Theme.current.applyTableSectionFooter(view)
    }

}
