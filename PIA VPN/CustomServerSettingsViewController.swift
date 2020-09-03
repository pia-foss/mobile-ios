//
//  CustomServerSettingsViewController.swift
//  PIA VPN
//  
//  Created by Jose Antonio Blaya Garcia on 02/03/2020.
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

import UIKit
import PIALibrary

class CustomServerSettingsViewController: AutolayoutViewController {

    //server:country:hostname:ip:udp_port:tcp_port

    @IBOutlet private weak var textServerName: BorderedTextField!
    @IBOutlet private weak var textServerCountry: BorderedTextField!
    @IBOutlet private weak var textServerHostname: BorderedTextField!
    @IBOutlet private weak var textServerIp: BorderedTextField!
    @IBOutlet private weak var textServerUDPPort: BorderedTextField!
    @IBOutlet private weak var textServerTCPPort: BorderedTextField!

    override func viewDidLoad() {
        
        self.title = "Custom Servers"
        configureTextfields()
        configureNavigationBar()

        super.viewDidLoad()
        
    }
    
    // MARK: Actions
    @objc private func update(_ sender: Any?) {
        if let name = textServerName.text,
            let country = textServerCountry.text,
            let hostname = textServerHostname.text,
            let address = textServerIp.text,
            let tcp = textServerUDPPort.text,
            let udp = textServerTCPPort.text,
            let tcpPort = UInt16(tcp),
            let udpPort = UInt16(udp) {

            let server = Server(
                serial: "\(Int.random(in: 100000 ... 999999))",
                name: name,
                country: country,
                hostname: hostname,
                bestOpenVPNAddressForTCP: Server.Address(hostname: address, port: tcpPort),
                bestOpenVPNAddressForUDP: Server.Address(hostname: address, port: udpPort),
                pingAddress: nil,
                regionIdentifier: ""
            )
            
            if AppConstants.Servers.customServers == nil {
                AppConstants.Servers.customServers = [server]
            }else {
                AppConstants.Servers.customServers?.append(server)
            }
            
            self.navigationController?.popViewController(animated: true)
        } else {
            let alertController = Macros.alert("",
                                               "You must provide a valid server information")
            alertController.addCancelAction(L10n.Global.close)

        }
    }
    
    // MARK: Private
    private func configureNavigationBar() {

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: L10n.Global.add,
            style: .plain,
            target: self,
            action: #selector(update(_:))
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = L10n.Global.add
    }
    
    private func configureTextfields() {
        
        textServerName.placeholder = "Server name"
        textServerCountry.placeholder = "Server country"
        textServerHostname.placeholder = "Hostname"
        textServerIp.placeholder = "Hostname IP Address"
        textServerTCPPort.placeholder = "TCP Port"
        textServerUDPPort.placeholder = "UDP Port"

    }

    // MARK: Restylable
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle("Custom servers")
        
        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        
        Theme.current.applyInput(textServerName)
        Theme.current.applyInput(textServerCountry)
        Theme.current.applyInput(textServerHostname)
        Theme.current.applyInput(textServerIp)
        Theme.current.applyInput(textServerUDPPort)
        Theme.current.applyInput(textServerTCPPort)

    }

}
