//
//  UIDevice+WIFI.swift
//  PIA VPN
//
//  Created by Said Rehouni on 7/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SystemConfiguration
import NetworkExtension
import UIKit

extension UIDevice {
    var WiFiSSID: String? {
        guard let interfaces = NEHotspotHelper.supportedNetworkInterfaces(),
              interfaces.count > 0,
              let interface = interfaces[0] as? NEHotspotNetwork,
            !interface.ssid.isEmpty else {
            return nil
        }
        return interface.ssid
    }
}
