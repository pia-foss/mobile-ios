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
        let showReconnectNotifications = Client.preferences.showReconnectNotifications

        // If disconnected, connect right away
        if !isConnected {
            connect(to: server)
            return
        }

        // If same server was selected, do nothing
        guard (server.identifier != currentServer.identifier || server.dipToken != currentServer.dipToken) else {
            return
        }

        // Present reconnection warning if enabled in preferences, otherwise reconnect right away
        if showReconnectNotifications {
            let alert = Macros.alert(
                L10n.Localizable.Dashboard.Vpn.ChangeLocation.Alert.title,
                L10n.Localizable.Dashboard.Vpn.ChangeLocation.Alert.message
            )

            // reconnect -> reconnect VPN and close
            alert.addActionWithTitle(L10n.Localizable.Dashboard.Vpn.ChangeLocation.Alert.Button.connect) {
                self.connect(to: server)
            }

            // cancel -> do nothing
            alert.addCancelActionWithTitle(L10n.Localizable.Global.cancel) {}

            present(alert, animated: true)
        } else {
            connect(to: server)
        }
    }

    private func connect(to server: Server) {
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
