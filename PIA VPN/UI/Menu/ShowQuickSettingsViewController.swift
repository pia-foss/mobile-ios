//
//  ShowQuickSettingsViewController.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 12/11/2019.
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

private enum QuickSettingOptions: Int {
    case theme = 0
    case killswitch
    case networkTools
    case privateBrowsing
    
    static func totalCount() -> Int {
        return !Flags.shared.enablesThemeSwitch ? 3 : 4
    }
    
    static func options() -> [QuickSettingOptions] {
        return !Flags.shared.enablesThemeSwitch ?
            [killswitch, networkTools, privateBrowsing] :
            [theme, killswitch, networkTools, privateBrowsing]
    }
}

class ShowQuickSettingsCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingImage: UIImageView!

}

class ShowQuickSettingsViewController: AutolayoutViewController {

    @IBOutlet private weak var tableView: UITableView!
    private lazy var switchThemeSettings = UISwitch()
    private lazy var switchKillSwitchSetting = UISwitch()
    private lazy var switchNetworkToolsSetting = UISwitch()
    private lazy var switchPrivateBrowserSetting = UISwitch()
    
    private let settingCellIdentifier = "SettingCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1.0
        
        switchThemeSettings.addTarget(self, action: #selector(toggleThemeSetting), for: .valueChanged)
        switchKillSwitchSetting.addTarget(self, action: #selector(toggleKillSwitchSetting), for: .valueChanged)
        switchNetworkToolsSetting.addTarget(self, action: #selector(toggleNetworkToolsSetting), for: .valueChanged)
        switchPrivateBrowserSetting.addTarget(self, action: #selector(togglePrivateBrowserSetting), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBarWithTitle(L10n.Localizable.Tiles.Quicksettings.title)
    }

    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(L10n.Localizable.Tiles.Quicksettings.title)
    }
    
    // MARK: Switch actions
    @objc private func toggleThemeSetting(_ sender: UISwitch) {
        if enabledSettingsCount() == 1 && !sender.isOn {
            cancelDisablingAction()
            return
        }
        AppPreferences.shared.quickSettingThemeVisible = sender.isOn
        tableView.reloadData()
        Macros.postNotification(.PIATilesDidChange)
    }

    @objc private func toggleKillSwitchSetting(_ sender: UISwitch) {
        if enabledSettingsCount() == 1 && !sender.isOn {
            cancelDisablingAction()
            return
        }
        AppPreferences.shared.quickSettingKillswitchVisible = sender.isOn
        tableView.reloadData()
        Macros.postNotification(.PIATilesDidChange)
    }

    @objc private func toggleNetworkToolsSetting(_ sender: UISwitch) {
        if enabledSettingsCount() == 1 && !sender.isOn {
            cancelDisablingAction()
            return
        }
        AppPreferences.shared.quickSettingNetworkToolVisible = sender.isOn
        tableView.reloadData()
        Macros.postNotification(.PIATilesDidChange)
    }

    @objc private func togglePrivateBrowserSetting(_ sender: UISwitch) {
        if enabledSettingsCount() == 1 && !sender.isOn {
            cancelDisablingAction()
            return
        }
        AppPreferences.shared.quickSettingPrivateBrowserVisible = sender.isOn
        tableView.reloadData()
        Macros.postNotification(.PIATilesDidChange)
    }
    
    private func cancelDisablingAction() {
        tableView.reloadData()
        let alert = Macros.alert(
            L10n.Localizable.Tiles.Quicksettings.title,
            L10n.Localizable.Tiles.Quicksettings.Min.Elements.message
        )
        alert.addActionWithTitle(L10n.Localizable.Global.ok) {
        }
        present(alert, animated: true, completion: nil)
    }

    private func enabledSettingsCount() -> Int {
        return (Flags.shared.enablesThemeSwitch && AppPreferences.shared.quickSettingThemeVisible).intValue +
        AppPreferences.shared.quickSettingKillswitchVisible.intValue +
        AppPreferences.shared.quickSettingNetworkToolVisible.intValue +
        AppPreferences.shared.quickSettingPrivateBrowserVisible.intValue
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        styleNavigationBarWithTitle(L10n.Localizable.Tiles.Quicksettings.title)

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
        return QuickSettingOptions.totalCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingCellIdentifier, for: indexPath)
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.selectionStyle = .none

        if let cell = cell as? ShowQuickSettingsCell {
            let options = QuickSettingOptions.options()
            let option = options[indexPath.row]
            switch option {
            case .theme:
                cell.titleLabel.text = L10n.Localizable.Settings.ApplicationSettings.ActiveTheme.title
                cell.accessoryView = switchThemeSettings
                cell.settingImage.image = Theme.current.palette.appearance == .light ? Asset.Images.Piax.Global.themeLightInactive.image :
                Asset.Images.Piax.Global.themeDarkInactive.image
                cell.settingImage.accessibilityLabel = L10n.Localizable.Settings.ApplicationSettings.ActiveTheme.title
                switchThemeSettings.isOn = AppPreferences.shared.quickSettingThemeVisible
            case .killswitch:
                cell.titleLabel.text = L10n.Localizable.Settings.ApplicationSettings.KillSwitch.title
                cell.accessoryView = switchKillSwitchSetting
                cell.settingImage.image = Theme.current.palette.appearance == .light ? Asset.Images.Piax.Global.killswitchLightInactive.image :
                Asset.Images.Piax.Global.killswitchDarkInactive.image
                cell.settingImage.accessibilityLabel = L10n.Localizable.Settings.ApplicationSettings.KillSwitch.title
                switchKillSwitchSetting.isOn = AppPreferences.shared.quickSettingKillswitchVisible
            case .networkTools:
                cell.titleLabel.text = L10n.Localizable.Tiles.Quicksetting.Nmt.title
                cell.accessoryView = switchNetworkToolsSetting
                cell.settingImage.image = Theme.current.palette.appearance == .light ? Asset.Images.Piax.Global.nmtLightInactive.image :
                Asset.Images.Piax.Global.nmtDarkInactive.image
                cell.settingImage.accessibilityLabel = L10n.Localizable.Tiles.Quicksetting.Nmt.title
                switchNetworkToolsSetting.isOn = AppPreferences.shared.quickSettingNetworkToolVisible
            case .privateBrowsing:
                cell.titleLabel.text = L10n.Localizable.Tiles.Quicksetting.Private.Browser.title
                cell.accessoryView = switchPrivateBrowserSetting
                cell.settingImage.image = Theme.current.palette.appearance == .light ? Asset.Images.Piax.Global.browserLightInactive.image :
                Asset.Images.Piax.Global.browserDarkInactive.image
                cell.settingImage.accessibilityLabel = L10n.Localizable.Tiles.Quicksetting.Private.Browser.title
                switchPrivateBrowserSetting.isOn = AppPreferences.shared.quickSettingPrivateBrowserVisible
            }
            Theme.current.applySettingsCellTitle(cell.titleLabel,
                                                 appearance: .dark)
            cell.titleLabel.backgroundColor = .clear
        }

        Theme.current.applySecondaryBackground(cell)
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

