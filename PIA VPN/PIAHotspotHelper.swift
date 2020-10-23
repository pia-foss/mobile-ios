//
//  PIAHotspotHelper.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 18/12/2018.
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
import NetworkExtension
import PIALibrary
import SwiftyBeaver

private let log = SwiftyBeaver.self

public protocol PIAHotspotHelperDelegate: class {

    /**
     Refreshes the available WiFi networks.
     
     - Parameter callback: Returns a refreshed list of available SSIDs as `String`.
     */
    func refreshAvailableNetworks(_ networks: [String]?)

}

class PIAHotspotHelper {
    
    private var delegate: PIAHotspotHelperDelegate?
    
    init(withDelegate delegate: PIAHotspotHelperDelegate? = nil) {
        self.delegate = delegate
    }
    
    /**
     Returns the current WiFi SSID.
     
     - Returns: SSID as `String`.
     */
    public func currentWiFiNetwork() -> String? {
        return UIDevice.current.WiFiSSID
    }
    
    /**
     Configures the HotspotHelper API to perform actions depending of the command.
     
     - Returns: true if correctly configured.
     */
    public func configureHotspotHelper() -> Bool {
        
        guard Client.preferences.nmtRulesEnabled else {
            return false
        }
        
        var options: [String: NSObject] = [:]
        if Client.preferences.nmtRulesEnabled {
            options = [kNEHotspotHelperOptionDisplayName : self.hotspotHelperMessage() as NSObject]
        }
        NEHotspotHelper.supportedNetworkInterfaces()
        return NEHotspotHelper.register(options: options,
                                        queue: DispatchQueue.main) { [weak self] (cmd: NEHotspotHelperCommand) in
                                            
                                            if let weakSelf = self {
                                                if cmd.commandType == .filterScanList {
                                                    log.info("filtering ssid list")
                                                    var availableList: [String] = []
                                                    var unsecuredList: [NEHotspotNetwork] = []
                                                    for element in cmd.networkList! {
                                                        if !element.ssid.isEmpty,
                                                            !availableList.contains(element.ssid) {
                                                            availableList.append(element.ssid)
                                                        }
                                                        if !element.isSecure {
                                                            element.setConfidence(.high)
                                                            unsecuredList.append(element)
                                                        }
                                                    }
                                                    weakSelf.saveCurrentNetworkList(availableNetworks: availableList)
                                                    let response = cmd.createResponse(NEHotspotHelperResult.success)
                                                    if !Client.providers.vpnProvider.isVPNConnected {
                                                        response.setNetworkList(unsecuredList)
                                                        log.info("present PIA message for unprotected networks")
                                                    }
                                                    response.deliver()
                                                } else if cmd.commandType == .evaluate {
                                                        if let currentNetwork = cmd.network {
                                                            if !currentNetwork.isSecure { // Open WiFi
                                                                log.info("Evaluate")

                                                                guard Client.providers.accountProvider.isLoggedIn else {
                                                                    return
                                                                }

                                                                let preferences = Client.preferences.editable()
                                                                preferences.nmtTemporaryOpenNetworks = [currentNetwork.ssid]
                                                                preferences.commit()
                                                                
                                                                if Client.preferences.nmtRulesEnabled {
                                                                    if Client.providers.vpnProvider.isVPNConnected {
                                                                        Client.providers.vpnProvider.reconnect(after: 0, forceDisconnect: true, nil)
                                                                    } else {
                                                                        Client.providers.vpnProvider.connect(nil)
                                                                    }
                                                                }
                                                                
                                                            }
                                                        }
                                                    }
                                            } 
                                            
        }
        
    }
    
    private func hotspotHelperMessage() -> String {
        if Client.preferences.nmtRulesEnabled,
            Client.preferences.useWiFiProtection {
            return L10n.Hotspothelper.Display.Protected.name
        } else {
            return L10n.Hotspothelper.Display.name
        }
    }
    
    private func saveCurrentNetworkList(availableNetworks: [String]) {
        let preferences = Client.preferences.editable()
        preferences.availableNetworks = availableNetworks
        preferences.commit()
    }
    
    /**
     List of available networks.
     
     - Returns: Array of available SSID.
     */
    public func retrieveCurrentNetworkList() -> [String] {
        var availableNetworks = Client.preferences.availableNetworks
        if let ssid = UIDevice.current.WiFiSSID,
            !availableNetworks.contains(ssid) {
            availableNetworks.append(ssid)
        }
        return availableNetworks
    }
    
    /**
     List of trusted networks.
     
     - Returns: Array of trusted SSID.
     */
    public func trustedNetworks() -> [String] {
        return Client.preferences.trustedNetworks
    }
    
    /**
     Saves the WiFi network.
     
     - Parameter ssid: SSID as `String`.
     */
    public func saveTrustedNetwork(_ ssid: String) {
        var trustedNetworks = Client.preferences.trustedNetworks
        if !trustedNetworks.contains(ssid) {
            trustedNetworks.append(ssid)
        }
        let preferences = Client.preferences.editable()
        preferences.trustedNetworks = trustedNetworks
        preferences.commit()
    }
    
    /**
     Removes the WiFi networks.
     
     - Parameter ssid: SSID as `String`.
     */
    public func removeTrustedNetwork(_ ssid: String) {
        let trustedNetworks = Client.preferences.trustedNetworks
        let newTrustedNetworks = trustedNetworks.filter { $0 != ssid }
        let preferences = Client.preferences.editable()
        preferences.trustedNetworks = newTrustedNetworks
        preferences.commit()
    }
    
    /**
     Remove all elements from the trusted network list.
     */
    public func clearTrustedNetworkList() {
        var trustedNetworks = Client.preferences.trustedNetworks
        trustedNetworks.removeAll()
        let preferences = Client.preferences.editable()
        preferences.trustedNetworks = trustedNetworks
        preferences.commit()
    }
    
}
