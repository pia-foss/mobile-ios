//
//  ClientAccess.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/22/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

protocol DatabaseAccess {
    var accessedDatabase: Client.Database { get }
}

protocol PreferencesAccess {
    var accessedPreferences: Client.Preferences { get }
}

protocol ConfigurationAccess {
    var accessedConfiguration: Client.Configuration { get }
}

protocol ProvidersAccess {
    var accessedProviders: Client.Providers { get }
}

protocol WebServicesAccess {
    var accessedWebServices: WebServices { get }
}

protocol InAppAccess {
    #if os(iOS)
    var accessedStore: InAppProvider { get }
    #endif
}

extension DatabaseAccess {
    var accessedDatabase: Client.Database {
        return Client.database
    }
}

extension PreferencesAccess {
    var accessedPreferences: Client.Preferences {
        return Client.preferences
    }
}

extension ConfigurationAccess {
    var accessedConfiguration: Client.Configuration {
        return Client.configuration
    }
}

extension ProvidersAccess {
    var accessedProviders: Client.Providers {
        return Client.providers
    }
}

extension WebServicesAccess {
    var accessedWebServices: WebServices {
        return Client.webServices
    }
}

extension InAppAccess {
    #if os(iOS)
    var accessedStore: InAppProvider {
        return Client.store
    }
    #endif
}
