//
//  PIAHotspotHelper.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 18/12/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
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
        
        let options: [String: NSObject] = [kNEHotspotHelperOptionDisplayName : self.hotspotHelperMessage() as NSObject]
        let queue: DispatchQueue = DispatchQueue(label: "com.privateinternetaccess.hotspot", attributes: DispatchQueue.Attributes.concurrent)
        NEHotspotHelper.supportedNetworkInterfaces()
        if Client.preferences.nmtRulesEnabled {
            return NEHotspotHelper.register(options: options,
                                            queue: queue) { [weak self] (cmd: NEHotspotHelperCommand) in
                                                
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
                                                    }

                                                    
                                                }
                                                
            }
        } else {
            return false
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
    
    private func tryToConnectVPNForAllNetworks() {
        if Client.preferences.shouldConnectForAllNetworks {
            //Connect the VPN
            if !Client.providers.vpnProvider.isVPNConnected {
                Macros.dispatch(after: .milliseconds(200)) {
                    Client.providers.vpnProvider.connect(nil)
                }
            }
        }
    }
    
}
