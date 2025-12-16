//
//  Flags.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/17/17.
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
import PIALibrary

class Flags: NSObject {
    static let shared = Flags()
    
    // initialize to production values here

    @objc private(set) var usesDevelopmentClient = false

    @objc private(set) var customizesClientEnvironment = false
    
    @objc private(set) var customizesWelcomePreset = false

    @objc private(set) var usesMockAccount = false

    @objc private(set) var usesMockInApp = false
    
    @objc private(set) var usesMockVPN = false

    @objc private(set) var alwaysShowsWalkthrough = false

    @objc private(set) var enablesResetSettings = true
    
    @objc private(set) var enablesProtocolSelection = true

    @objc private(set) var enablesMACESetting = false
    
    @objc private(set) var enablesContentBlockerSetting = true
    
    @objc private(set) var enablesEncryptionSettings = true

    @objc private(set) var enablesDevelopmentSettings = false

    @objc private(set) var customizesVPNRenegotiation = false
    
    @objc private(set) var enablesDNSSettings = true

    private(set) var enablesThemeSwitch = true
    
    private override init() {
        super.init()
        
        enablesThemeSwitch = false
        
        #if PIA_DEV
            guard let path = AppConstants.Flags.developmentPath else {
                fatalError("Couldn't find flags path")
            }
            load(from: path)
        #endif
    }
    
    private func load(from path: String) {
        guard let toggles = NSDictionary(contentsOfFile: path) as? [String: Bool] else {
            fatalError("Couldn't load plist from \(path)")
        }
        for (key, value) in toggles {
            setValue(value, forKeyPath: key)
        }
    }
}
