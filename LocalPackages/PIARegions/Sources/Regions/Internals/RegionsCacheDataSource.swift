/*
 *  Copyright (c) 2020 Private Internet Access, Inc.
 *
 *  This file is part of the Private Internet Access Mobile Client.
 *
 *  The Private Internet Access Mobile Client is free software: you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License as published by the Free
 *  Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  The Private Internet Access Mobile Client is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 *  details.
 *
 *  You should have received a copy of the GNU General Public License along with the Private
 *  Internet Access Mobile Client.  If not, see <https://www.gnu.org/licenses/>.
 */

import Foundation


internal struct CacheError: Error {
    let locale: String?

    var localizedDescription: String {
        if let locale, !locale.isEmpty {
            return "cache miss for locale = '\(locale)'"
        }
        return "cache miss"
    }
}

internal protocol RegionsCacheDataSource: Sendable {
    func saveVPNRegions(locale: String, response: VPNRegionsResponse)
    func getVPNRegions(locale: String?) -> Result<VPNRegionsResponse, Error>
    func saveShadowsocksRegions(locale: String, response: [ShadowsocksRegionsResponse])
    func getShadowsocksRegions(locale: String?) -> Result<[ShadowsocksRegionsResponse], Error>
}

internal protocol RegionsDataSourceFactory: Sendable {
    func newInMemoryDataSource() -> any RegionsCacheDataSource
    func newPersistenceRegionsDataSource(preferenceName: String?) -> any RegionsCacheDataSource
}

internal struct CacheEntry: Codable {
    var locale: String
    var regionsResponse: VPNRegionsResponse
}
