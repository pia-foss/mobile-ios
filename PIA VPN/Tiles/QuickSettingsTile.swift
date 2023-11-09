//
//  QuickSettingsTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 20/03/2019.
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

class QuickSettingsTile: UIView, Tileable  {
    
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal
    
    @IBOutlet private weak var tileTitle: UILabel!
    @IBOutlet private weak var themeButton: UIButton!
    @IBOutlet private weak var killSwitchButton: UIButton!
    @IBOutlet private weak var nmtButton: UIButton!
    @IBOutlet private weak var browserButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
        self.setupView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func hasDetailView() -> Bool {
        return true
    }
    
    private func setupView() {
        
        self.detailSegueIdentifier = StoryboardSegue.Main.showQuickSettingsViewController.rawValue

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(updateButtons), name: .PIASettingsHaveChanged, object: nil)
        nc.addObserver(self, selector: #selector(setupButtons), name: .PIASettingsHaveChanged, object: nil)
        nc.addObserver(self, selector: #selector(updateButtons), name: .PIAQuickSettingsHaveChanged, object: nil)
        nc.addObserver(self, selector: #selector(setupButtons), name: .PIAQuickSettingsHaveChanged, object: nil)
        nc.addObserver(self, selector: #selector(setupButtons), name: .PIATilesDidChange, object: nil)

        self.tileTitle.text = L10n.Tiles.Quicksettings.title.uppercased()

        setupButtons()
        viewShouldRestyle()
    }
    
    @objc private func setupButtons() {
        
        self.themeButton.isHidden = !Flags.shared.enablesThemeSwitch || !AppPreferences.shared.quickSettingThemeVisible
        self.killSwitchButton.isHidden = !AppPreferences.shared.quickSettingKillswitchVisible
        self.nmtButton.isHidden = !AppPreferences.shared.quickSettingNetworkToolVisible
        self.browserButton.isHidden = !AppPreferences.shared.quickSettingPrivateBrowserVisible

    }
    
    @objc private func viewShouldRestyle() {
        Theme.current.applyPrincipalBackground(self)
        tileTitle.style(style: TextStyle.textStyle21)
        updateButtons()
    }
    
    @objc private func updateButtons() {
        
        killSwitchButton.accessibilityLabel = L10n.Settings.ApplicationSettings.KillSwitch.title
        nmtButton.accessibilityLabel = L10n.Tiles.Quicksetting.Nmt.title
        browserButton.accessibilityLabel = L10n.Tiles.Quicksetting.Private.Browser.title

        if Flags.shared.enablesThemeSwitch {
            themeButton.accessibilityLabel = L10n.Settings.ApplicationSettings.ActiveTheme.title
            if AppPreferences.shared.currentThemeCode == ThemeCode.light {
                themeButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.themeLightActive.image :
                    Asset.Piax.Global.themeDarkActive.image, for: [])
            } else {
                themeButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.themeLightInactive.image :
                    Asset.Piax.Global.themeDarkInactive.image, for: [])
            }
        }

        if Client.preferences.isPersistentConnection {
            killSwitchButton.accessibilityLabel = L10n.Global.disable + " " + L10n.Settings.ApplicationSettings.KillSwitch.title
            killSwitchButton.setImage(Asset.Piax.Global.killswitchDarkActive.image, for: [])
        } else {
            killSwitchButton.accessibilityLabel = L10n.Global.enable + " " + L10n.Settings.ApplicationSettings.KillSwitch.title
            killSwitchButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.killswitchLightInactive.image :
                Asset.Piax.Global.killswitchDarkInactive.image, for: [])
        }
        
        if Client.preferences.nmtRulesEnabled {
            nmtButton.accessibilityLabel = L10n.Global.disable + " " + L10n.Tiles.Quicksetting.Nmt.title
            nmtButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.nmtLightActive.image :
                Asset.Piax.Global.nmtDarkActive.image, for: [])
        } else {
            nmtButton.accessibilityLabel = L10n.Global.enable + " " + L10n.Tiles.Quicksetting.Nmt.title
            nmtButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.nmtLightInactive.image :
                Asset.Piax.Global.nmtDarkInactive.image, for: [])
        }
        
        browserButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.browserLightInactive.image :
            Asset.Piax.Global.browserDarkInactive.image, for: [])
        
    }
    
    @IBAction func changeTheme(_ sender: Any) {
        
        if AppPreferences.shared.currentThemeCode == ThemeCode.light {
            AppPreferences.shared.transitionTheme(to: ThemeCode.dark)
        } else {
            AppPreferences.shared.transitionTheme(to: ThemeCode.light)
        }

        updateButtons()
        
    }

    @IBAction func updateKillSwitchSetting(_ sender: Any) {
        let preferences = Client.preferences.editable()
        preferences.isPersistentConnection = !Client.preferences.isPersistentConnection
        preferences.commit()

        updateProfile()
        updateButtons()
        presentKillSwitchAlertIfNeeded()

    }
    
    @IBAction func updateNMTSetting(_ sender: Any) {
        let preferences = Client.preferences.editable()
        preferences.nmtRulesEnabled = !Client.preferences.nmtRulesEnabled
        preferences.commit()
        
        updateProfile()
        updateButtons()
        presentKillSwitchAlertIfNeeded()
        
    }
    
    @IBAction func openBrowser(_ sender: Any) {
        
        if let browserUrl = URL(string: AppConstants.Browser.scheme) {
            if UIApplication.shared.canOpenURL(browserUrl) {
                UIApplication.shared.open(browserUrl)
            } else {
                if let itunesUrl = URL(string: AppConstants.Browser.appStoreUrl),
                    UIApplication.shared.canOpenURL(itunesUrl) {
                    UIApplication.shared.open(itunesUrl)
                } else {
                    guard let url = URL(string: AppConstants.Browser.safariUrl) else { return }
                    UIApplication.shared.open(url)
                }
            }
        }
        
    }
    
    private func presentKillSwitchAlertIfNeeded() {
        if !Client.preferences.isPersistentConnection,
            Client.preferences.nmtRulesEnabled {
            NotificationCenter.default.post(name: .PIAPersistentConnectionTileHaveChanged,
                                            object: self,
                                            userInfo: nil)
        }
    }
    
    private func updateProfile() {
        NotificationCenter.default.post(name: .PIAQuickSettingsHaveChanged,
                                        object: self,
                                        userInfo: nil)
    }
    
}
