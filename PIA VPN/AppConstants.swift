//
//  AppConstants.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/16/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

struct AppConstants {
    static let teamId = "5357M5NW9W"

    static let appGroup = "group.com.privateinternetaccess"
    
    static let hockeyAppId = "a2397c4240ac48e897e67498f0df0e1a"
    
    struct Flags {
        static var developmentPath = Bundle.main.path(forResource: "Flags-dev", ofType: "plist")
    }

    struct About {
        static var componentsPath = Bundle.main.path(forResource: "Components", ofType: "plist")
    }
    
    struct Regions {
        static var bundleURL = Bundle.main.url(forResource: "Regions", withExtension: "json")
    }

    struct InApp {
        static let yearlyProductIdentifier = "com.privateinternetaccess.ios.iap.1year"
        
        static let monthlyProductIdentifier = "com.privateinternetaccess.ios.iap.1month"
    }
    
    struct AppURL {
        static let hostRegion = "region"
    }
    
    struct Extensions {
        static let tunnelBundleIdentifier = "com.privateinternetaccess.ios.PIA-VPN.Tunnel"

        static let adBlockerBundleIdentifier = "com.privateinternetaccess.ios.PIA-VPN.AdBlocker"
    }
    
    struct Web {
        static let homeURL = URL(string: "https://www.privateinternetaccess.com/")!

        static let supportURL = URL(string: "https://helpdesk.privateinternetaccess.com/")!
        
        static let privacyURL = URL(string: "https://www.privateinternetaccess.com/pages/privacy-policy/")!

        static let csEmail = "helpdesk+vpnpermissions.ios@privateinternetaccess.com"

        static var stagingEndpointURL: URL? = {
            guard let path = Bundle.main.path(forResource: "staging", ofType: "endpoint") else {
                return nil
            }
            guard let content = try? String(contentsOfFile: path) else {
                return nil
            }
            return URL(string: content.trimmingCharacters(in: .whitespacesAndNewlines))
        }()
    }
    
    struct Fonts {
        static let typeface: Theme.Typeface = {
            let typeface = Theme.Typeface()
            typeface.regularName = "Roboto-Regular"
            typeface.mediumName = "Roboto-Medium"
            return typeface
        }()
    }
}
