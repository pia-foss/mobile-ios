//
//  ClientAccess.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/22/17.
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
