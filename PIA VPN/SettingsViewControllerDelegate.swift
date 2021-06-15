//
//  SettingsViewControllerDelegate.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 15/6/21.
//  Copyright © 2021 Private Internet Access, Inc.
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
import PIAWireguard
import TunnelKit

protocol SettingsViewControllerDelegate: AnyObject {
    
    var pendingOpenVPNSocketType: SocketType? { get set }

    var pendingOpenVPNConfiguration: OpenVPN.ConfigurationBuilder! { get set }

    var pendingWireguardVPNConfiguration: PIAWireguardConfiguration! { get set }

    /**
     Called to update the setting sent as parameter.
     
     - Parameter setting: The setting to update.
     - Parameter value: Optional value to update the setting
     */
    func updateSetting(_ setting: SettingSection, withValue value: Any?)
    
    /**
        Reset settings to default
     */
    func resetToDefaultSettings()
    
    /**
        Save VPN preferences
     */
    func savePreferences()

    /**
        Reloads the Settings table view
     */
    func refreshSettings()
    
    /**
        Updates the value for the VPN action
     */
    func reportUpdatedPreferences()
    
    /**
        Updates the socket type for OVPN
        - Parameter SocketType: UDP or TCP.
     */
    func updateSocketType(socketType: SocketType?)
    
    /**
        Updates the port for OVPN
        - Parameter UInt16: The available port retrieved from the region list.
     */
    func updateRemotePort(port: UInt16)
    
    /**
        Updates the encryption method for the VPN connection
        - Parameter String: The encryption method.
     */
    func updateDataEncryption(encryption value: String)
    
    /**
        Updates the handshake value
        - Parameter String: The handshake value.
     */
    func updateHandshake(handshake value: String)
    
}

