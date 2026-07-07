//
//  AppConstants.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/16/17.
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

import Foundation

public struct AppConstants {

    public static let appId = "955626407"
    public static let teamId = "5357M5NW9W"
    public static let appGroup = "group.com.privateinternetaccess"

    public struct Reviews {
        public static var appReviewUrl = "https://itunes.apple.com/app/id\(appId)?action=write-review"
        public static var feedbackUrl = "https://www.privateinternetaccess.com/helpdesk/new-ticket"
    }

    public struct About {
        public static var componentsPath = Bundle.main.path(forResource: "Components", ofType: "plist")
    }

    public struct RegionsGEN4 {
        public static var bundleURL = Bundle.main.url(forResource: "Regions", withExtension: "json")
    }

    public enum InApp {
        public static let yearlyProductIdentifier = "com.privateinternetaccess.subscription.year.May2026"
        public static let monthlyProductIdentifier = "com.privateinternetaccess.subscription.month.May2026"
    }

    public enum LegacyInApp {
        public static let yearlyOctober2020ProductIdentifier = "com.privateinternetaccess.subscription.year.october.2020"
        public static let monthlyOctober2020ProductIdentifier = "com.privateinternetaccess.subscription.month.october.2020"
        public static let yearly2020ProductIdentifier = "com.privateinternetaccess.subscription.1year.2020"
        public static let monthly2020ProductIdentifier = "com.privateinternetaccess.subscription.1month.2020"
        public static let yearlySubscriptionProductIdentifier = "com.privateinternetaccess.subscription.1year"
        public static let monthlySubscriptionProductIdentifier = "com.privateinternetaccess.subscription.1month"
        public static let yearlyProductIdentifier = "com.privateinternetaccess.ios.iap.2019.1year"
        public static let monthlyProductIdentifier = "com.privateinternetaccess.ios.iap.2019.1month"
        public static let oldYearlyProductIdentifier = "com.privateinternetaccess.ios.iap.1year"
        public static let oldMonthlyProductIdentifier = "com.privateinternetaccess.ios.iap.1month"
    }

    public struct AppURL {
        public static let hostRegion = "region"
    }

    public struct Extensions {
        // Legacy per-protocol extensions (pre-PlatformSDK); live only while `usePlatformSDKVPN` is off.
        public static let tunnelBundleIdentifier = Bundle.main.bundleIdentifier! + ".Tunnel"
        public static let tunnelWireguardBundleIdentifier = Bundle.main.bundleIdentifier! + ".WG-Tunnel"

        // PlatformSDK tunnel: a single extension handling OpenVPN and WireGuard, replacing the legacy pair above.
        public static let tunnelPlatformSDKBundleIdentifier = Bundle.main.bundleIdentifier! + ".PlatformSDK-Tunnel-iOS"
        public static let tunnelPlatformSDKTvOSBundleIdentifier = Bundle.main.bundleIdentifier! + ".PlatformSDK-Tunnel-tvOS"

        public static let adBlockerBundleIdentifier = "com.privateinternetaccess.ios.PIA-VPN.AdBlocker"
    }

    public struct SiriShortcuts {
        public static let shortcutConnect = "com.privateinternetaccess.ios.PIA-VPN.connect"
        public static let shortcutDisconnect = "com.privateinternetaccess.ios.PIA-VPN.disconnect"
    }

    public struct Web {
        public static let homeURL = URL(string: "https://www.privateinternetaccess.com/")!
        public static let supportURL = URL(string: "https://www.privateinternetaccess.com/helpdesk")!
        public static let privacyURL = URL(string: "https://www.privateinternetaccess.com/pages/privacy-policy/")!
        public static let deleteAccountUrl = URL(string: "https://helpdesk.privateinternetaccess.com/guides/account-changes/change-account-information/delete-pia-account")!
        public static let csEmail = "helpdesk+vpnpermissions.ios@privateinternetaccess.com"
        public static let leakProtectionURL = URL(string: "\(Self.supportURL.absoluteString)/kb/articles/what-is-pia-s-leak-protection-feature-on-ios")!
    }

    public struct Browser {
        public static let scheme = "inbrowser://?www.privateinternetaccess.com"
        public static let appStoreUrl = "itms-apps://itunes.apple.com/app/id598907571"
        public static let safariUrl = "https://apps.apple.com/us/app/inbrowser-private-browsing/id598907571?ls=1"
    }

    public struct OpenVPNPacketSize {
        public static let defaultPacketSize = 1400
        public static let smallPacketSize = 1350
    }

    public struct IKEv2PacketSize {
        public static let defaultPacketSize = 0
        public static let highPacketSize = 1420
    }

    public struct WireGuardPacketSize {
        public static let defaultPacketSize = 1280
        public static let highPacketSize = 1420
    }

    /// App-group UserDefaults keys read by the PlatformSDK tunnel, keeping its config path
    /// independent of the `TunnelKitOpenVPN`/`PIAWireguard` packages. The writer is
    /// `AppPreferences` (app target); its `Entries` use the same literal strings, so these
    /// values MUST stay in sync with that file.
    public struct UserDefaultsKeys {
        public struct OpenVPN {
            /// Cipher, stored as its OpenVPN raw value (e.g. "AES-128-GCM").
            public static let cipher = "OpenVPNCipher"
            /// Auth digest, stored as its OpenVPN raw value (e.g. "SHA256").
            public static let auth = "OpenVPNAuth"
            /// Preferred port, stored as an `Int`; 0 means automatic.
            public static let port = "OpenVPNPort"
            /// Selected transport, stored as a `SocketType` raw value ("UDP"/"TCP"); absent = automatic.
            public static let transport = "PIASocketType"
            /// Small-packets toggle (`Bool`).
            public static let useSmallPackets = "UseSmallPackets"
        }

        public struct WireGuard {
            /// Small-packets toggle (`Bool`).
            public static let useSmallPackets = "WireGuardUseSmallPackets"
        }
    }

    public struct MagicLink {
        public static let url = "piavpn:login?token="
    }

    public struct Widget {
        public static let connect = "piavpn:connect"
    }

    public struct QRSignin {
        public static let url = "piavpn:loginqr?token="
    }

    public struct HotspotHelper {
        public static let queueLabel = "com.privateinternetaccess.hotspothelper"
    }
}
