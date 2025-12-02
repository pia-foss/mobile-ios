//
//  NetworkMonitor.swift
//  PIA VPN
//
//  Created by Said Rehouni on 14/8/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol NetworkMonitor {
    func checkForRFC1918Vulnerability() -> Bool
    func isConnected() -> Bool
}
