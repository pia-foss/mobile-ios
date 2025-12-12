//
//  SiriShortcutsManager.swift
//  PIA VPN
//  
//  Created by Jose Antonio Blaya Garcia on 17/04/2020.
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

import Foundation
import IntentsUI
import Intents
import PIALibrary

public class SiriShortcutsManager: NSObject {

    public static let shared = SiriShortcutsManager()

    func presentConnectShortcut(inViewController viewController: UIViewController) {
    
        if AppPreferences.shared.useConnectSiriShortcuts {
            if let shortcut = AppPreferences.shared.connectShortcut {
                let shortcutViewController = INUIEditVoiceShortcutViewController(voiceShortcut: shortcut)
                shortcutViewController.delegate = self
                viewController.present(shortcutViewController, animated: true, completion: nil)
            }
        } else {
            let connectShortcut = SiriShortcutConnect().build()
            
            let shortcutViewController = INUIAddVoiceShortcutViewController(shortcut: connectShortcut)
            shortcutViewController.delegate = self
            viewController.present(shortcutViewController, animated: true, completion: nil)
        }

    }
    
    func presentDisconnectShortcut(inViewController viewController: UIViewController) {
    
        if AppPreferences.shared.useDisconnectSiriShortcuts {
            if let shortcut = AppPreferences.shared.disconnectShortcut {
                let shortcutViewController = INUIEditVoiceShortcutViewController(voiceShortcut: shortcut)
                shortcutViewController.delegate = self
                viewController.present(shortcutViewController, animated: true, completion: nil)
            }
        } else {

            let disconnectShortcut = SiriShortcutDisconnect().build()

            let shortcutViewController = INUIAddVoiceShortcutViewController(shortcut: disconnectShortcut)
            shortcutViewController.delegate = self
            viewController.present(shortcutViewController, animated: true, completion: nil)
        }

    }
    
    func descriptionActionForConnectShortcut() -> String {
        if AppPreferences.shared.useConnectSiriShortcuts {
            return L10n.Localizable.Global.edit
        } else {
            return L10n.Localizable.Global.add
        }
    }
    
    func descriptionActionForDisconnectShortcut() -> String {
        if AppPreferences.shared.useDisconnectSiriShortcuts {
            return L10n.Localizable.Global.edit
        } else {
            return L10n.Localizable.Global.add
        }
    }
    
}

extension SiriShortcutsManager: INUIAddVoiceShortcutViewControllerDelegate {
    
    public func addVoiceShortcutViewController(
        _ controller: INUIAddVoiceShortcutViewController,
        didFinishWith voiceShortcut: INVoiceShortcut?,
        error: Error?
        ) {
        if let _ = error {
            let message = L10n.Localizable.Siri.Shortcuts.Add.error
            let alert = Macros.alert(nil, message)
            alert.addCancelActionWithTitle(L10n.Localizable.Global.cancel) {
                controller.dismiss(animated: true, completion: nil)
            }
            controller.present(alert, animated: true, completion: nil)
        } else {
            if let activityType = voiceShortcut?.shortcut.userActivity?.activityType {
                if activityType == AppConstants.SiriShortcuts.shortcutConnect {
                    AppPreferences.shared.useConnectSiriShortcuts = true
                    AppPreferences.shared.connectShortcut = voiceShortcut
                } else {
                    AppPreferences.shared.useDisconnectSiriShortcuts = true
                    AppPreferences.shared.disconnectShortcut = voiceShortcut
                }
            }
            NotificationCenter.default.post(name: .RefreshSettings, object: self, userInfo: nil)
            controller.dismiss(animated: true, completion: nil)
        }
    }

    public func addVoiceShortcutViewControllerDidCancel(
        _ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    
}

extension SiriShortcutsManager: INUIEditVoiceShortcutViewControllerDelegate {
    
    public func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let error = error as? INIntentError {
            if let errorDescription = error.userInfo["NSDebugDescription"] as? String,
                let connectIdentifier = AppPreferences.shared.connectShortcut?.identifier.uuidString,
                errorDescription.contains(connectIdentifier) {
                AppPreferences.shared.useConnectSiriShortcuts = false
                AppPreferences.shared.connectShortcut = nil
            } else if let errorDescription = error.userInfo["NSDebugDescription"] as? String,
                let disconnectIdentifier = AppPreferences.shared.disconnectShortcut?.identifier.uuidString,
                errorDescription.contains(disconnectIdentifier) {
                AppPreferences.shared.useDisconnectSiriShortcuts = false
                AppPreferences.shared.disconnectShortcut = nil
            }
        }
        NotificationCenter.default.post(name: .RefreshSettings, object: self, userInfo: nil)
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        if deletedVoiceShortcutIdentifier == AppPreferences.shared.connectShortcut?.identifier {
            AppPreferences.shared.useConnectSiriShortcuts = false
            AppPreferences.shared.connectShortcut = nil
        } else {
            AppPreferences.shared.useDisconnectSiriShortcuts = false
            AppPreferences.shared.disconnectShortcut = nil
        }
        NotificationCenter.default.post(name: .RefreshSettings, object: self, userInfo: nil)
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    
}
