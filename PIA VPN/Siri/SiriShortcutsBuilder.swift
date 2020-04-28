//
//  SiriShortcutsBuilder.swift
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
import Intents

@available(iOS 12.0, *)
protocol SiriShortcutBuilder {
    
    var activityType: String { get set }
    var title: String { get set }
    var persistentIdentifier: String { get set }

    func build() -> INShortcut
    
}

@available(iOS 12.0, *)
extension SiriShortcutBuilder {
    
    func build() -> INShortcut {
        let connectActivity = NSUserActivity(activityType: activityType)
        connectActivity.title = title
        connectActivity.isEligibleForSearch = true
        connectActivity.isEligibleForPrediction = true
        connectActivity.persistentIdentifier = NSUserActivityPersistentIdentifier(persistentIdentifier)
        return INShortcut(userActivity: connectActivity)
    }
    
}

@available(iOS 12.0, *)
class SiriShortcutConnect: SiriShortcutBuilder {
    
    var activityType = AppConstants.SiriShortcuts.shortcutConnect
    var title = L10n.Siri.Shortcuts.Connect.title
    var persistentIdentifier = AppConstants.SiriShortcuts.shortcutConnect

}

@available(iOS 12.0, *)
class SiriShortcutDisconnect: SiriShortcutBuilder {
    
    var activityType = AppConstants.SiriShortcuts.shortcutDisconnect
    var title = L10n.Siri.Shortcuts.Disconnect.title
    var persistentIdentifier = AppConstants.SiriShortcuts.shortcutDisconnect

}
