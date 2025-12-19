//
//  SettingOptions.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 14/5/21.
//  Copyright © 2021 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import Foundation
import PIALibrary
import UIKit

public enum SettingOptions: Int, EnumsBuilder {

    case general
    case protocols
    case network
    case privacyFeatures
    case automation
    case help
    case development

    public func localizedTitleMessage() -> String {
        switch self {
            case .general: return L10n.Localizable.Settings.Section.general
            case .protocols: return L10n.Localizable.Settings.Section.protocols
            case .network: return L10n.Localizable.Settings.Section.network
            case .privacyFeatures: return L10n.Localizable.Settings.Section.privacyFeatures
            case .automation: return L10n.Localizable.Settings.Section.automation
            case .help: return L10n.Localizable.Settings.Section.help
            case .development: return "Development"
        }
    }
    
    public func localizedSubtitleMessage() -> String {
        switch self {
            case .general: return ""
            case .protocols: return ""
            case .network: return ""
            case .privacyFeatures: return ""
            case .automation: return ""
            case .help: return ""
            case .development: return ""
        }
    }

    public func imageForSection() -> UIImage {
        switch self {
            case .general: return Asset.Images.Piax.Settings.iconGeneral.image
            case .protocols: return Asset.Images.Piax.Settings.iconProtocols.image
            case .network: return Asset.Images.Piax.Settings.iconNetwork.image
            case .privacyFeatures: return Asset.Images.Piax.Settings.iconPrivacy.image
            case .automation: return Asset.Images.Piax.Settings.iconAutomation.image
            case .help: return Asset.Images.Piax.Settings.iconAbout.image
            case .development: return Asset.Images.Piax.Settings.iconGeneral.image
        }
    }

    public func sectionsForSetting() -> [SettingSection] {
        switch self {
            case .general: return GeneralSections.all()
            case .protocols: return ProtocolsSections.all()
            case .network: return NetworkSections.all()
            case .privacyFeatures: return PrivacyFeaturesSections.all()
            case .automation: return AutomationSections.all()
            case .help: return HelpSections.all()
            case .development: return DevelopmentSections.all()
        }
    }
    
    public static func all() -> [Self] {
        return [.general, .protocols, .network, .privacyFeatures, .automation, .help, .development]
    }
    
}

public protocol SettingSection {
    
    func localizedTitleMessage() -> String
    func localizedSubtitleMessage() -> String
    
}

public enum GeneralSections: Int, SettingSection, EnumsBuilder {
    
    case connectSiri
    case disconnectSiri
    case showServiceCommunicationMessages
    case showGeoRegions
    case resetSettings
    
    public func localizedTitleMessage() -> String {
        switch self {
            case .connectSiri: return L10n.Localizable.Siri.Shortcuts.Connect.Row.title
            case .disconnectSiri: return L10n.Localizable.Siri.Shortcuts.Disconnect.Row.title
            case .showGeoRegions: return L10n.Localizable.Settings.Geo.Servers.description
            case .showServiceCommunicationMessages: return L10n.Localizable.Inapp.Messages.Toggle.title
            case .resetSettings: return L10n.Localizable.Settings.Reset.Defaults.title
        }
    }
    
    public func localizedSubtitleMessage() -> String {
        switch self {
            case .connectSiri: return ""
            case .disconnectSiri: return ""
            case .showGeoRegions: return ""
            case .showServiceCommunicationMessages: return ""
            case .resetSettings: return ""
        }
    }
    
    public static func all() -> [Self] {
        return [.connectSiri, .disconnectSiri, .showServiceCommunicationMessages, .showGeoRegions, .resetSettings]
    }

}

public enum ProtocolsSections: Int, SettingSection, EnumsBuilder {
    
    case protocolSelection
    case transport
    case remotePort
    case dataEncryption
    case handshake
    case useSmallPackets
    
    public func localizedTitleMessage() -> String {
        switch self {
            case .protocolSelection: return L10n.Localizable.Settings.Connection.VpnProtocol.title
            case .transport: return L10n.Localizable.Settings.Connection.Transport.title
            case .remotePort: return L10n.Localizable.Settings.Connection.RemotePort.title
            case .dataEncryption: return L10n.Localizable.Settings.Encryption.Cipher.title
            case .handshake: return L10n.Localizable.Settings.Encryption.Handshake.title
            case .useSmallPackets: return L10n.Localizable.Settings.Small.Packets.title
        }
    }
    
    public func localizedSubtitleMessage() -> String {
        switch self {
            case .protocolSelection: return ""
            case .transport: return ""
            case .remotePort: return ""
            case .dataEncryption: return ""
            case .handshake: return ""
            case .useSmallPackets: return ""
        }
    }
    
    public static func all() -> [Self] {
        return [.protocolSelection, .transport, .remotePort, .dataEncryption, .handshake, .useSmallPackets]
    }

}

public enum NetworkSections: Int, SettingSection, EnumsBuilder {
    
    case dns
    
    public func localizedTitleMessage() -> String {
        switch self {
            case .dns: return "DNS"
        }
    }
    
    public func localizedSubtitleMessage() -> String {
        switch self {
        case .dns: return ""
        }
    }
    
    public static func all() -> [Self] {
        return [.dns]
    }

}

public enum PrivacyFeaturesSections: Int, SettingSection, EnumsBuilder {
    
    case killswitch = 0
    case reconnectNotifications
    case leakProtection
    case allowAccessOnLocalNetwork
    case safariContentBlocker
    case refresh

    public func localizedTitleMessage() -> String {
        switch self {
            case .killswitch: return L10n.Localizable.Settings.ApplicationSettings.KillSwitch.title
            case .reconnectNotifications: return L10n.Localizable.Settings.ApplicationSettings.ReconnectNotifications.title
            case .leakProtection: return L10n.Localizable.Settings.ApplicationSettings.LeakProtection.title
            case .allowAccessOnLocalNetwork: return L10n.Localizable.Settings.ApplicationSettings.AllowLocalNetwork.title
            case .safariContentBlocker: return L10n.Localizable.Settings.ContentBlocker.title
            case .refresh: return L10n.Localizable.Settings.ContentBlocker.Refresh.title
        }
    }
    
    public func localizedSubtitleMessage() -> String {
        switch self {
            case .killswitch: return ""
            case .reconnectNotifications: return ""
            case .leakProtection: return ""
            case .allowAccessOnLocalNetwork: return ""
            case .safariContentBlocker: return ""
            case .refresh: return ""
        }
    }
    
    public static func all() -> [Self] {
        return [.killswitch, .reconnectNotifications, .leakProtection, .allowAccessOnLocalNetwork, .safariContentBlocker, .refresh]
    }

}

public enum AutomationSections: Int, SettingSection, EnumsBuilder {
    
    case automation
    case manageAutomation

    public func localizedTitleMessage() -> String {
        switch self {
            case .automation: return L10n.Localizable.Network.Management.Tool.Enable.automation
            case .manageAutomation: return L10n.Localizable.Network.Management.Tool.title
        }
    }
    
    public func localizedSubtitleMessage() -> String {
        switch self {
        case .automation: return ""
        case .manageAutomation: return ""
        }
    }
    
    public static func all() -> [Self] {
        return [.automation, .manageAutomation]
    }

}

public enum HelpSections: Int, SettingSection, EnumsBuilder {
    
    case sendDebugLogs
    case kpiShareStatistics
    case kpiViewEvents
    case latestNews
    case version

    public func localizedTitleMessage() -> String {
        switch self {
        case .sendDebugLogs: return L10n.Localizable.Settings.ApplicationInformation.Debug.title
        case .kpiShareStatistics: return L10n.Localizable.Settings.Service.Quality.Share.title
        case .kpiViewEvents: return L10n.Localizable.Settings.Service.Quality.Show.title
        case .latestNews: return L10n.Localizable.Settings.Cards.History.title
        case .version: return L10n.Localizable.Global.version
        }
    }
    
    public func localizedSubtitleMessage() -> String {
        switch self {
        case .sendDebugLogs: return ""
        case .kpiShareStatistics: return ""
        case .kpiViewEvents: return ""
        case .latestNews: return ""
        case .version: return ""
        }
    }
    
    public static func all() -> [Self] {
        return [.sendDebugLogs, .kpiShareStatistics, .latestNews, .version]
    }
    
    public static func allWithEvents() -> [Self] {
        return [.sendDebugLogs, .kpiShareStatistics, .kpiViewEvents, .latestNews, .version,]
    }

}

public enum DevelopmentSections: Int, SettingSection, EnumsBuilder {
    
    case stagingVersion
    case customServers
    case publicUsername
    case username
    case password
    case environment
    case resolveGoogleAdsDomain
    case deleteKeychain
    case crash
    case leakProtectionFlag
    case leakProtectionNotificationsFlag
    case dynamicIslandLiveActivityFlag

    public func localizedTitleMessage() -> String {
        switch self {
        case .stagingVersion: return "Staging version"
        case .customServers: return "Custom servers"
        case .publicUsername: return "Public Username"
        case .username: return "Username"
        case .password: return "Password"
        case .environment: return "Environment"
        case .resolveGoogleAdsDomain: return "Resolve Google Ads Domain"
        case .deleteKeychain: return "Delete the Keychain"
        case .crash: return "Crash the app"
        case .leakProtectionFlag: return "FF - Leak Protection"
        case .leakProtectionNotificationsFlag: return "FF - Leak Protection Notifications"
        case .dynamicIslandLiveActivityFlag: return "FF - Dynamic Island Live Activity"
        }
    }
    
    public func localizedSubtitleMessage() -> String {
        switch self {
        case .stagingVersion: return ""
        case .customServers: return ""
        case .publicUsername: return ""
        case .username: return ""
        case .password: return ""
        case .environment: return ""
        case .resolveGoogleAdsDomain: return ""
        case .deleteKeychain: return ""
        case .crash: return ""
        case .leakProtectionFlag: return ""
        case .leakProtectionNotificationsFlag: return ""
        case .dynamicIslandLiveActivityFlag: return ""
        }
    }
    
    public static func all() -> [Self] {
      return [.stagingVersion, .customServers, .publicUsername, .username, .password, .environment, .resolveGoogleAdsDomain, .deleteKeychain, .crash, .leakProtectionFlag, .leakProtectionNotificationsFlag, .dynamicIslandLiveActivityFlag]
    }

}

