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

import PIAAssetsMobile
import PIADesignSystem
import PIALibrary
import PIALocalizations
import PIAUIKit
import UIKit

final class QuickSettingsTile: UIView, Tileable {

    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal

    @IBOutlet private weak var tileTitle: UILabel!
    @IBOutlet private weak var killSwitchButton: UIButton!
    @IBOutlet private weak var automationButton: UIButton!
    @IBOutlet private weak var browserButton: UIButton!
    @IBOutlet private weak var buttonsStackView: UIStackView!

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

    private func setupView() {

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(updateButtons), name: .PIAAccountDidLogin, object: nil)
        nc.addObserver(self, selector: #selector(updateButtons), name: .PIASettingsHaveChanged, object: nil)
        nc.addObserver(self, selector: #selector(updateButtons), name: .PIAQuickSettingsHaveChanged, object: nil)

        self.tileTitle.text = L10n.Tiles.Quicksettings.title.uppercased()

        viewShouldRestyle()
    }

    @objc private func viewShouldRestyle() {
        Theme.current.applyPrincipalBackground(self)
        tileTitle.style(style: TextStyle.textStyle21)
        updateButtons()
    }

    @objc private func updateButtons() {

        killSwitchButton.accessibilityLabel = L10n.Settings.ApplicationSettings.KillSwitch.title
        automationButton.accessibilityLabel = L10n.Tiles.Quicksetting.Automation.title
        browserButton.accessibilityLabel = L10n.Tiles.Quicksetting.Private.Browser.title

        if Client.preferences.isPersistentConnection {
            killSwitchButton.accessibilityLabel = L10n.Global.disable + " " + L10n.Settings.ApplicationSettings.KillSwitch.title
            killSwitchButton.setImage(Asset.Piax.Global.killswitchActive.image, for: [])
        } else {
            killSwitchButton.accessibilityLabel = L10n.Global.enable + " " + L10n.Settings.ApplicationSettings.KillSwitch.title
            killSwitchButton.setImage(Asset.Piax.Global.killswitchInactive.image, for: [])
        }

        if Client.preferences.nmtRulesEnabled {
            automationButton.accessibilityLabel = L10n.Global.disable + " " + L10n.Tiles.Quicksetting.Automation.title
            automationButton.setImage(Asset.Piax.Global.nmtActive.image, for: [])
        } else {
            automationButton.accessibilityLabel = L10n.Global.enable + " " + L10n.Tiles.Quicksetting.Automation.title
            automationButton.setImage(Asset.Piax.Global.nmtInactive.image, for: [])
        }

        browserButton.setImage(Asset.Piax.Global.browserInactive.image, for: [])

    }

    // Automation runs on the kill switch's on-demand rules, so it only works while the kill switch is on. Changes that
    // would leave Automation on without the kill switch go through the dashboard's alerts instead.

    @IBAction func updateKillSwitchSetting(_ sender: Any) {
        if Client.preferences.isPersistentConnection, Client.preferences.nmtRulesEnabled {
            NotificationCenter.default.post(name: .PIAKillSwitchDisableNeedsConfirmation, object: self)
            return
        }

        let preferences = Client.preferences.editable()
        preferences.isPersistentConnection = !Client.preferences.isPersistentConnection
        preferences.commit()

        updateProfile()
        updateButtons()
        showKillSwitchFeedback()
    }

    @IBAction func updateNMTSetting(_ sender: Any) {
        if !Client.preferences.nmtRulesEnabled, !Client.preferences.isPersistentConnection {
            NotificationCenter.default.post(name: .PIAAutomationRequiresKillSwitch, object: self)
            return
        }

        let preferences = Client.preferences.editable()
        preferences.nmtRulesEnabled = !Client.preferences.nmtRulesEnabled
        preferences.commit()

        updateProfile()
        updateButtons()
        showAutomationFeedback()
    }

    @IBAction func openBrowser(_ sender: Any) {

        if let browserUrl = URL(string: AppConstants.Browser.scheme) {
            if UIApplication.shared.canOpenURL(browserUrl) {
                UIApplication.shared.open(browserUrl)
            } else {
                if let itunesUrl = URL(string: AppConstants.Browser.appStoreUrl),
                    UIApplication.shared.canOpenURL(itunesUrl)
                {
                    UIApplication.shared.open(itunesUrl)
                } else {
                    guard let url = URL(string: AppConstants.Browser.safariUrl) else { return }
                    UIApplication.shared.open(url)
                }
            }
        }

    }

    // MARK: Feedback

    // The shortcuts are icon-only, so a banner names what was just switched.

    private func showKillSwitchFeedback() {
        if Client.preferences.isPersistentConnection {
            showFeedback(L10n.Tiles.Quicksettings.Killswitch.enabled, image: Asset.Piax.Global.killswitchActive.image, isEnabled: true)
        } else {
            showFeedback(L10n.Tiles.Quicksettings.Killswitch.disabled, image: Asset.Piax.Global.killswitchInactive.image, isEnabled: false)
        }
    }

    private func showAutomationFeedback() {
        if Client.preferences.nmtRulesEnabled {
            showFeedback(L10n.Tiles.Quicksettings.Automation.enabled, image: Asset.Piax.Global.nmtActive.image, isEnabled: true)
        } else {
            showFeedback(L10n.Tiles.Quicksettings.Automation.disabled, image: Asset.Piax.Global.nmtInactive.image, isEnabled: false)
        }
    }

    private func showFeedback(_ message: String, image: UIImage, isEnabled: Bool) {
        if isEnabled {
            Macros.displaySuccessImageNote(withImage: image, message: message)
        } else {
            Macros.displayWarningImageNote(withImage: image, message: message)
        }
    }

    private func updateProfile() {
        NotificationCenter.default.post(
            name: .PIAQuickSettingsHaveChanged,
            object: self,
            userInfo: nil)
    }

}
