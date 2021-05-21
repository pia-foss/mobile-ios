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
            case .general: return "General"
            case .protocols: return "Protocols"
            case .network: return "Network"
            case .privacyFeatures: return "Privacy Features"
            case .automation: return "Automation"
            case .help: return "Help"
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
            case .connectSiri: return "Connect Siri"
            case .disconnectSiri: return "Disconnect Siri"
            case .showGeoRegions: return "Show Geo-located Regions"
            case .showServiceCommunicationMessages: return "Show Service Communication Messages"
            case .resetSettings: return "Reset settings to default"
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
            case .protocolSelection: return "Protocol Selection"
            case .transport: return "Transport"
            case .remotePort: return "Remote Port"
            case .dataEncryption: return "Data Encryption"
            case .handshake: return "Handshake"
            case .useSmallPackets: return "Use Small Packets"
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
    
    case killswitch
    case safariContentBlocker
    case refresh

    public func localizedTitleMessage() -> String {
        switch self {
        case .killswitch: return "VPN Kill Switch"
        case .safariContentBlocker: return "Safari Content blocker state"
        case .refresh: return "Refresh block list"
        }
    }
    
    public func localizedSubtitleMessage() -> String {
        switch self {
        case .killswitch: return ""
        case .safariContentBlocker: return ""
        case .refresh: return ""
        }
    }
    
    public static func all() -> [Self] {
        return [.killswitch, .safariContentBlocker, .refresh]
    }

}

public enum AutomationSections: Int, SettingSection, EnumsBuilder {
    
    case automation
    case manageAutomation

    public func localizedTitleMessage() -> String {
        switch self {
        case .automation: return "Enable Automation"
        case .manageAutomation: return "Manage Automation"
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
    case latestNews
    case version

    public func localizedTitleMessage() -> String {
        switch self {
        case .sendDebugLogs: return "Send Debug Log to support"
        case .latestNews: return "Latest News"
        case .version: return "Version"
        }
    }
    
    public func localizedSubtitleMessage() -> String {
        switch self {
        case .sendDebugLogs: return ""
        case .latestNews: return ""
        case .version: return ""
        }
    }
    
    public static func all() -> [Self] {
        return [.sendDebugLogs, .latestNews, .version]
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
    case crash

    public func localizedTitleMessage() -> String {
        switch self {
        case .stagingVersion: return "Staging version"
        case .customServers: return "Custom servers"
        case .publicUsername: return "Public Username"
        case .username: return "Username"
        case .password: return "Password"
        case .environment: return "Environment"
        case .resolveGoogleAdsDomain: return "Resolve Google Ads Domain"
        case .crash: return "Crash the app"
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
        case .crash: return ""
        }
    }
    
    public static func all() -> [Self] {
        return [.stagingVersion, .customServers, .publicUsername, .username, .password, .environment, .resolveGoogleAdsDomain, .crash]
    }

}

