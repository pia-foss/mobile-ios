//
//  MessagesCommands.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 10/11/2020.
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
import UIKit
import PIALibrary
import PIAWireguard
import TunnelKitCore
import TunnelKitOpenVPN

private let log = PIALogger.logger(for: ActionCommand.self)

protocol Command {
    func execute()
}

class LinkCommand: Command {

    private var payload: String

    init(_ payload: String) {
        self.payload = payload
    }

    func execute() {
        if let url = URL(string: payload),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

class ViewCommand: Command {
    
    private enum AvailableViews: String {
        case settings = "settings"
        case regions = "regions"
        case account = "account"
        case dip = "dip"
        case about = "about"
    }

    private var payload: String

    init(_ payload: String) {
        self.payload = payload
        
        if let view = AvailableViews(rawValue: payload) {
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let rootNavVC = appDelegate.window?.rootViewController as? UINavigationController,
                let dashboard = rootNavVC.viewControllers.first as? DashboardViewController {

                switch view {
                case .about:
                    dashboard.openAbout()
                case .account:
                    dashboard.openAccount()
                case .dip:
                    dashboard.openDedicatedIp()
                case .regions:
                    dashboard.selectRegion(animated: true)
                case .settings:
                    dashboard.openSettings()
                }
                
            }

        }
        
    }

    func execute() {
    }
}

class ActionCommand: Command {

    private enum AvailableActions: String {
        case killswitch = "killswitch"
        case nmt = "nmt"
        case ovpn = "ovpn"
        case wg = "wg"
        case ikev2 = "ikev2"
        case geo = "geo"
    }

    private var payload: [String: Bool]

    init(_ payload: [String: Bool]) {
        
        self.payload = payload
        
        self.payload.forEach({ key, value in
            
            if let action = AvailableActions(rawValue: key) {
                switch action {
                case .killswitch:
                    enableKillSwitch(enable: value)
                case .nmt:
                    enableNMT(enable: value)
                case .ovpn:
                    if value {
                        activateOpenVPN()
                    }
                case .wg:
                    if value {
                        activateWireGuard()
                    }
                case .ikev2:
                    if value {
                        activateIKEv2()
                    }
                case .geo:
                    enableGEOServers(enable: value)
                }
            }

        })
        
        Macros.postNotification(.PIASettingsHaveChanged)

    }

    func execute() {
    }
    
    private func activateWireGuard() {
        
        let preferences = Client.preferences.editable()
        guard let currentVPNConfiguration = preferences.vpnCustomConfiguration(for: PIAWGTunnelProfile.vpnType) as? PIAWireguardConfiguration ??
            Client.preferences.defaults.vpnCustomConfiguration(for: PIAWGTunnelProfile.vpnType) as? PIAWireguardConfiguration else {
            log.error("No default VPN custom configuration provided for PIA Wireguard protocol")
            return
        }

        preferences.setVPNCustomConfiguration(currentVPNConfiguration, for: PIAWGTunnelProfile.vpnType)
        preferences.vpnType = PIAWGTunnelProfile.vpnType
        preferences.commit()

    }
    
    private func activateOpenVPN() {
        
        let preferences = Client.preferences.editable()
        guard let currentVPNConfiguration = preferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNProvider.Configuration ??
            Client.preferences.defaults.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNProvider.Configuration else {
            log.error("No default VPN custom configuration provided for PIA OpenVPN protocol")
            return
        }

        preferences.setVPNCustomConfiguration(currentVPNConfiguration, for: PIATunnelProfile.vpnType)
        preferences.vpnType = PIATunnelProfile.vpnType
        preferences.commit()

    }

    private func activateIKEv2() {
        let preferences = Client.preferences.editable()
        preferences.vpnType = IKEv2Profile.vpnType
        preferences.commit()
    }
    
    private func enableKillSwitch(enable: Bool) {
        let preferences = Client.preferences.editable()
        preferences.isPersistentConnection = enable
        preferences.commit()
    }
    
    private func enableNMT(enable: Bool) {
        let preferences = Client.preferences.editable()
        preferences.nmtRulesEnabled = enable
        if enable {
            preferences.isPersistentConnection = enable
        }
        preferences.commit()
    }
    
    private func enableGEOServers(enable: Bool) {
        AppPreferences.shared.showGeoServers = enable
        NotificationCenter.default.post(name: .PIADaemonsDidPingServers,
                                        object: self,
                                        userInfo: nil)
    }

}
