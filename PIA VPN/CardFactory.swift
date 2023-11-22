//
//  CardFactory.swift
//  PIA VPN
//  
//  Created by Jose Antonio Blaya Garcia on 09/07/2020.
//  Copyright © 2020 Private Internet Access, Inc.
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

import Foundation
import PIALibrary
import PIAWireguard
import UIKit

struct CardFactory {
    
    static func getCardsForVersion(_ appVersion: String?) -> [Card] {
        
        let cards = getAllCards().filter({ $0.version == appVersion })
        return cards
        
    }
    
    static func getAllCards() -> [Card] {
        let cards = Self.availableCards
        cards.forEach { $0.hideCTA() }
        return cards
    }
    
    private static let availableCards = [
        Card("3.7.1",
             L10n.Localizable.Card.Wireguard.title,
             L10n.Localizable.Card.Wireguard.description,
             "wg-background-",
             "wg-main",
             L10n.Localizable.Card.Wireguard.Cta.activate,
             URL(string: "https://www.privateinternetaccess.com/blog/wireguide-all-about-the-wireguard-vpn-protocol/"), {
                
                guard let rootView = AppDelegate.delegate().topViewControllerWithRootViewController(rootViewController: UIApplication.shared.keyWindow?.rootViewController) else {
                    return
                }
                
                if rootView is SettingsViewController {
                    NotificationCenter.default.post(name: .RefreshWireGuardSettings,
                    object: nil,
                    userInfo: nil)
                } else {
                    if Client.providers.vpnProvider.isVPNConnected {
                        NotificationCenter.default.post(name: .OpenSettingsAndActivateWireGuard,
                        object: nil,
                        userInfo: nil)
                    } else {
                        Self.activateWireGuard()
                        NotificationCenter.default.post(name: .OpenSettings,
                        object: nil,
                        userInfo: nil)
                    }
                }

        }),
    ]
    
    private static func activateWireGuard() {
        
        if Client.preferences.vpnType == PIAWGTunnelProfile.vpnType,
            Client.providers.vpnProvider.isVPNConnected {
            return
        }
        
        let preferences = Client.preferences.editable()
        guard let currentWireguardVPNConfiguration = preferences.vpnCustomConfiguration(for: PIAWGTunnelProfile.vpnType) as? PIAWireguardConfiguration ??
            Client.preferences.defaults.vpnCustomConfiguration(for: PIAWGTunnelProfile.vpnType) as? PIAWireguardConfiguration else {
            fatalError("No default VPN custom configuration provided for PIA Wireguard protocol")
        }

        preferences.setVPNCustomConfiguration(currentWireguardVPNConfiguration, for: PIAWGTunnelProfile.vpnType)
        preferences.vpnType = PIAWGTunnelProfile.vpnType
        preferences.commit()
        
        Macros.postNotification(.PIASettingsHaveChanged)
        Macros.postNotification(.ReloadSettings)
        Macros.postNotification(.ResetSettingsNavigationStack)

    }
    
    private static func connect() {
        Client.providers.vpnProvider.install(force: true, { _ in
            Client.providers.vpnProvider.connect(nil)
        })
    }
}


