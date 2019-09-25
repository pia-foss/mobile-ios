//
//  QuickSettingsTile.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 20/03/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class QuickSettingsTile: UIView, Tileable  {
    
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal
    
    @IBOutlet private weak var themeButton: UIButton!
    @IBOutlet private weak var killSwitchButton: UIButton!
    @IBOutlet private weak var nmtButton: UIButton!
    @IBOutlet private weak var themeLabel: UILabel!
    @IBOutlet private weak var killSwitchLabel: UILabel!
    @IBOutlet private weak var nmtLabel: UILabel!

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
        return false
    }
    
    private func setupView() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(updateButtons), name: .PIASettingsHaveChanged, object: nil)
        
        setupThemeButton()
        viewShouldRestyle()
    }
    
    private func setupThemeButton() {
        if !Flags.shared.enablesThemeSwitch {
            if let stackView = self.themeButton.superview as? UIStackView {
                stackView.removeFromSuperview()
            }
            if let stackView = self.themeLabel.superview as? UIStackView {
                stackView.removeFromSuperview()
            }
        }
    }
    
    @objc private func viewShouldRestyle() {
        if Flags.shared.enablesThemeSwitch {
            Theme.current.applySubtitleTileUsage(themeLabel, appearance: .dark)
        }
        Theme.current.applySubtitleTileUsage(killSwitchLabel, appearance: .dark)
        Theme.current.applySubtitleTileUsage(nmtLabel, appearance: .dark)
        Theme.current.applyPrincipalBackground(self)
        updateButtons()
    }
    
    @objc private func updateButtons() {
        
        killSwitchLabel.text = L10n.Settings.ApplicationSettings.KillSwitch.title
        killSwitchLabel.textAlignment = .center
        nmtLabel.text = L10n.Tiles.Quicksetting.Nmt.title
        nmtLabel.textAlignment = .center
        killSwitchButton.accessibilityLabel = L10n.Settings.ApplicationSettings.KillSwitch.title
        nmtButton.accessibilityLabel = L10n.Tiles.Quicksetting.Nmt.title

        if Flags.shared.enablesThemeSwitch {
            themeLabel.text = L10n.Settings.ApplicationSettings.ActiveTheme.title
            themeLabel.textAlignment = .center
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
            killSwitchButton.setImage(Asset.Piax.Global.killswitchDarkActive.image, for: [])
        } else {
            killSwitchButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.killswitchLightInactive.image :
                Asset.Piax.Global.killswitchDarkInactive.image, for: [])
        }
        
        if Client.preferences.nmtRulesEnabled {
            nmtButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.nmtLightActive.image :
                Asset.Piax.Global.nmtDarkActive.image, for: [])
        } else {
            nmtButton.setImage(Theme.current.palette.appearance == .light ? Asset.Piax.Global.nmtLightInactive.image :
                Asset.Piax.Global.nmtDarkInactive.image, for: [])
        }
        
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
    }
    
    @IBAction func updateNMTSetting(_ sender: Any) {
        let preferences = Client.preferences.editable()
        preferences.nmtRulesEnabled = !Client.preferences.nmtRulesEnabled
        preferences.commit()
        
        updateProfile()
        updateButtons()

        if !Client.preferences.isPersistentConnection,
            Client.preferences.nmtRulesEnabled {
            NotificationCenter.default.post(name: .PIAPersistentConnectionTileHaveChanged,
                                            object: self,
                                            userInfo: nil)
        }
    }
    
    private func updateProfile() {
        NotificationCenter.default.post(name: .PIASettingsHaveChanged,
                                        object: self,
                                        userInfo: nil)
    }
    
}
