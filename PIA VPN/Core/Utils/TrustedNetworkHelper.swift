//
//  TrustedNetworkHelper.swift
//  PIA VPN
//
//  Created by Miguel Berrocal on 30/7/21.
//  Copyright © 2021 Private Internet Access Inc. All rights reserved.
//

import PIALibrary
import WidgetKit

class TrustedNetworkUtils {
    
    static var isTrustedNetwork: Bool {
        if Client.preferences.nmtRulesEnabled {
            if let ssid = PIAHotspotHelper().currentWiFiNetwork() {
                if Client.preferences.nmtGenericRules[NMTType.protectedWiFi.rawValue] == NMTRules.alwaysDisconnect.rawValue ||
                    (Client.preferences.nmtTrustedNetworkRules[ssid] == NMTRules.alwaysDisconnect.rawValue){
                    setWidgetTrustedNetworkStatus(isTrustedNetwork: true)
                    return true
                }
            } else {
                if Client.preferences.nmtGenericRules[NMTType.cellular.rawValue] == NMTRules.alwaysDisconnect.rawValue {
                    setWidgetTrustedNetworkStatus(isTrustedNetwork: true)
                    return true
                }
            }
        }
        setWidgetTrustedNetworkStatus(isTrustedNetwork: false)
        return false
    }
    
    private static func setWidgetTrustedNetworkStatus(isTrustedNetwork: Bool) {
        AppPreferences.shared.todayWidgetTrustedNetwork = isTrustedNetwork
        reloadWidget()
    }
    
    private static func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "PIAWidget")
    }
}
