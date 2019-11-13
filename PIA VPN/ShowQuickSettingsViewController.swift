//
//  ShowQuickSettingsViewController.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 12/11/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

private struct QuickSettingCells {
    static let setting = "SettingCell"
}

class ShowQuickSettingsViewController: AutolayoutViewController {

    @IBOutlet private weak var tableView: UITableView!
    private lazy var switchKillSwitchSetting = UISwitch()
    private lazy var switchNetworkToolsSetting = UISwitch()
    private lazy var switchPrivateBrowserSetting = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1.0
        
        switchKillSwitchSetting.addTarget(self, action: #selector(toggleKillSwitchSetting), for: .valueChanged)
        switchNetworkToolsSetting.addTarget(self, action: #selector(toggleNetworkToolsSetting), for: .valueChanged)
        switchPrivateBrowserSetting.addTarget(self, action: #selector(togglePrivateBrowserSetting), for: .valueChanged)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Tiles.Quicksettings.title)
    }

    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(L10n.Tiles.Quicksettings.title)
    }
    
    // MARK: Switch actions
    
    @objc private func toggleKillSwitchSetting(_ sender: UISwitch) {
        AppPreferences.shared.quickSettingKillswitchVisible = sender.isOn
        tableView.reloadData()
        Macros.postNotification(.PIATilesDidChange)
    }

    @objc private func toggleNetworkToolsSetting(_ sender: UISwitch) {
        AppPreferences.shared.quickSettingNetworkToolVisible = sender.isOn
        tableView.reloadData()
        Macros.postNotification(.PIATilesDidChange)
    }

    @objc private func togglePrivateBrowserSetting(_ sender: UISwitch) {
        AppPreferences.shared.quickSettingPrivateBrowserVisible = sender.isOn
        tableView.reloadData()
        Macros.postNotification(.PIATilesDidChange)
    }


    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        styleNavigationBarWithTitle(L10n.Tiles.Quicksettings.title)

        // XXX: for some reason, UITableView is not affected by appearance updates
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        Theme.current.applyPrincipalBackground(tableView)
        Theme.current.applyDividerToSeparator(tableView)
        tableView.reloadData()
        
    }

}

extension ShowQuickSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QuickSettingCells.setting, for: indexPath)
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.selectionStyle = .none

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = L10n.Settings.ApplicationSettings.KillSwitch.title
            cell.accessoryView = switchKillSwitchSetting
            switchKillSwitchSetting.isOn = AppPreferences.shared.quickSettingKillswitchVisible
        case 1:
            cell.textLabel?.text = L10n.Tiles.Quicksetting.Nmt.title
            cell.accessoryView = switchNetworkToolsSetting
            switchNetworkToolsSetting.isOn = AppPreferences.shared.quickSettingNetworkToolVisible
        case 2:
            cell.textLabel?.text = L10n.Tiles.Quicksetting.Private.Browser.title
            cell.accessoryView = switchPrivateBrowserSetting
            switchPrivateBrowserSetting.isOn = AppPreferences.shared.quickSettingPrivateBrowserVisible
        default:
            break
        }

        Theme.current.applySecondaryBackground(cell)
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

