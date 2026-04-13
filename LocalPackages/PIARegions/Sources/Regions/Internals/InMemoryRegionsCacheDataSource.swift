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

// NSLock guards all mutable state, making @unchecked Sendable legitimate here.
internal final class InMemoryRegionsCacheDataSource: RegionsCacheDataSource, @unchecked Sendable {
    private let lock = NSLock()
    private var vpnRegionsCacheEntry: CacheEntry?
    private var shadowsocksRegionsEntry: [ShadowsocksRegionsResponse] = []

    func saveVPNRegions(locale: String, response: VPNRegionsResponse) {
        lock.withLock {
            vpnRegionsCacheEntry = CacheEntry(locale: locale, regionsResponse: response)
        }
    }

    func getVPNRegions(locale: String?) -> Result<VPNRegionsResponse, Error> {
        lock.withLock {
            guard let entry = vpnRegionsCacheEntry else {
                return .failure(CacheError(locale: locale))
            }
            guard locale == nil || entry.locale == locale else {
                return .failure(CacheError(locale: locale))
            }
            return .success(entry.regionsResponse)
        }
    }

    func saveShadowsocksRegions(locale: String, response: [ShadowsocksRegionsResponse]) {
        lock.withLock {
            shadowsocksRegionsEntry = response
        }
    }

    func getShadowsocksRegions(locale: String?) -> Result<[ShadowsocksRegionsResponse], Error> {
        lock.withLock {
            guard !shadowsocksRegionsEntry.isEmpty else {
                return .failure(RegionsError.emptyShadowsocksEntry)
            }
            return .success(shadowsocksRegionsEntry)
        }
    }
}
