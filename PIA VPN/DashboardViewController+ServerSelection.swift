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

            let alert = Macros.alert(
                L10n.Localizable.Dashboard.Vpn.ChangeLocation.Alert.title,
                L10n.Localizable.Dashboard.Vpn.ChangeLocation.Alert.message
            )

            // reconnect -> reconnect VPN and close
            alert.addActionWithTitle(L10n.Localizable.Settings.Commit.Buttons.reconnect) {
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
