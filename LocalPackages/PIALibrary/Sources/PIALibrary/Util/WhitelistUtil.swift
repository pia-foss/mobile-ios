//
//  WhitelistUtil.swift
//  PIALibrary-iOS
//
//  Created by Waleed Mahmood on 01.06.22.
//  Copyright © 2022 London Trust Media. All rights reserved.
//

import Foundation
import SwiftyBeaver

private let log = SwiftyBeaver.self

public class WhitelistUtil {
    
    public static func filter(preferences: [String: Any], from filterKeys: [String] = WhitelistUtil.keys()) -> [String: Any] {
        return preferences.filter({ filterKeys.contains($0.key) })
    }
    
    public static func keys() -> [String] {
        return ["Version",
                "AddingEmojiKeybordHandled",
                "com.apple.content-rating.ExplicitMusicPodcastsAllowed",
                "RegionFilter",
                "AppleLanguagesDidMigrate",
                "vpn.button.description",
                "vpn.widget.port",
                "UseConnectSiriShortcuts",
                "NSLanguages",
                "Theme",
                "ShowGeoServers",
                "AppleLanguages",
                "vpn.widget.socket",
                "usesCustomDNS",
                "PKKeychainVersionKey",
                "UseSmallPackets",
                "AppEnvironmentIsProduction",
                "showServiceMessages",
                "INNextHearbeatDate",
                "DismissedMessages",
                "AKLastEmailListRequestDateKey",
                "checksDipExpirationRequest",
                "AKLastIDMSEnvironment",
                "quickSettingKillswitchVisible",
                "userInteractedWithSurvey",
                "quickSettingPrivateBrowserVisible",
                "successConnections",
                "successDisconnections",
                "DidAskToEnableNotifications",
                "ApplePasscodeKeyboards",
                "vpn.widget.trusted.network",
                "quickSettingNetworkToolVisible",
                "StagingVersion",
                "com.apple.content-rating.TVShowRating",
                "IKEV2UseSmallPackets",
                "com.apple.content-rating.AppRating",
                "canAskAgainForReview",
                "WireGuardUseSmallPackets",
                "NSAllowsDefaultLineBreakStrategy",
                "UseDisconnectSiriShortcuts",
                "AppleLocale",
                "com.apple.content-rating.MovieRating",
                "NSInterfaceStyle",
                "disablesMultiDipTokens",
                "quickSettingThemeVisible",
                "PKLogNotificationServiceResponsesKey",
                "com.apple.content-rating.ExplicitBooksAllowed",
                "AppleITunesStoreItemKinds",
                "AppleLanguagesSchemaVersion",
                "vpn.widget.protocol",
                "failureConnections",
                "Launched",
                "showsDedicatedIPView",
                "INNextFreshmintRefreshDateKey",
                "AppVersion"]
    }
}
