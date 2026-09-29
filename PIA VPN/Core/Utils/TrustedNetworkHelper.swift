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
        #if targetEnvironment(macCatalyst)
            let hasCellular = false
        #else
            let hasCellular = true
        #endif

        return isTrustedNetwork(
            ssid: PIAHotspotHelper().currentWiFiNetwork(),
            isOnWiFi: WiFiPathMonitor.shared.isOnWiFi,
            hasCellular: hasCellular
        )
    }

    static func isTrustedNetwork(ssid: String?, isOnWiFi: Bool, hasCellular: Bool) -> Bool {
        let alwaysDisconnect = NMTRules.alwaysDisconnect.rawValue
        let genericRules = Client.preferences.nmtGenericRules
        let isTrusted: Bool

        if !Client.preferences.nmtRulesEnabled {
            isTrusted = false
        } else if let ssid {
            isTrusted = genericRules[NMTType.protectedWiFi.rawValue] == alwaysDisconnect || Client.preferences.nmtTrustedNetworkRules[ssid] == alwaysDisconnect
        } else if isOnWiFi {
            // The SSID is unavailable on Mac Catalyst, the generic Wi-Fi rule still applies
            isTrusted = genericRules[NMTType.protectedWiFi.rawValue] == alwaysDisconnect
        } else if !hasCellular {
            // Without cellular (Mac) this is Ethernet, which no rule covers
            isTrusted = false
        } else {
            isTrusted = genericRules[NMTType.cellular.rawValue] == alwaysDisconnect
        }

        setWidgetTrustedNetworkStatus(isTrustedNetwork: isTrusted)
        return isTrusted
    }

    private static func setWidgetTrustedNetworkStatus(isTrustedNetwork: Bool) {
        AppPreferences.shared.todayWidgetTrustedNetwork = isTrustedNetwork
        reloadWidget()
    }

    private static func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "PIAWidget")
    }
}
