//
//  DashboardViewController+ServerSelection.swift
//  PIA VPN
//
//  Created by Miguel Berrocal on 30/7/21.
//  Copyright © 2021 Private Internet Access Inc. All rights reserved.
//

import PIALibrary

extension DashboardViewController: ServerSelectionDelegate {
    
    func didSelectServer(_ server: Server) {
        
        let isConnected = Client.providers.vpnProvider.isVPNConnected
        let currentServer = Client.preferences.displayedServer
        if isConnected {
            guard (server.identifier != currentServer.identifier || server.dipToken != currentServer.dipToken) else {
                return
            }
        }
        if TrustedNetworkUtils.isTrustedNetwork {
            showAutomationAlert() {
                Client.configuration.connectedManually = true
                Client.preferences.displayedServer = server
            }
        }
        else {
            Client.configuration.connectedManually = true

            //Setting this triggers a connection attempt
            Client.preferences.displayedServer = server
        }
    }
}
