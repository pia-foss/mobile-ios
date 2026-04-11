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


// @unchecked Sendable is safe here: all access to `userDefaults` is serialised through `lock`.
internal final class PersistenceRegionsDataSource: RegionsCacheDataSource, @unchecked Sendable {

    private static let tag = "PersistenceRegionsDataSource"
    private static let vpnRegionsEntryKey = "persist_region_entry"
    private static let shadowsocksRegionsEntryKey = "shadowsocks-regions-entry-key"

    private let userDefaults: UserDefaults
    private let logErrorsEnabled: Bool
    private let lock = NSLock()

    init(preferenceName: String? = nil, logErrors: Bool) {
        self.userDefaults = UserDefaults(suiteName: preferenceName ?? "PersistenceRegionsDataSource") ?? .standard
        self.logErrorsEnabled = logErrors
    }

    // MARK: - RegionsCacheDataSource

    func saveVPNRegions(locale: String, response: VPNRegionsResponse) {
        let entry = CacheEntry(locale: locale, regionsResponse: response)
        do {
            let data = try JSONEncoder().encode(entry)
            guard let jsonEntry = String(data: data, encoding: .utf8) else { return }
            store(key: Self.vpnRegionsEntryKey, value: jsonEntry)
        } catch {
            log(error.localizedDescription)
        }
    }

    func getVPNRegions(locale: String?) -> Result<VPNRegionsResponse, Error> {
        guard let jsonEntry = retrieve(key: Self.vpnRegionsEntryKey), !jsonEntry.isEmpty else {
            return .failure(CacheError(locale: locale))
        }
        guard let data = jsonEntry.data(using: .utf8) else {
            return .failure(CacheError(locale: locale))
        }
        let entry: CacheEntry
        do {
            entry = try JSONDecoder().decode(CacheEntry.self, from: data)
        } catch {
            log(error.localizedDescription)
            return .failure(CacheError(locale: locale))
        }
        guard locale == nil || entry.locale == locale else {
            return .failure(CacheError(locale: locale))
        }
        return .success(entry.regionsResponse)
    }

    func saveShadowsocksRegions(locale: String, response: [ShadowsocksRegionsResponse]) {
        do {
            let data = try JSONEncoder().encode(response)
            guard let jsonEntry = String(data: data, encoding: .utf8) else { return }
            store(key: Self.shadowsocksRegionsEntryKey, value: jsonEntry)
        } catch {
            log(error.localizedDescription)
        }
    }

    func getShadowsocksRegions(locale: String?) -> Result<[ShadowsocksRegionsResponse], Error> {
        guard let jsonEntry = retrieve(key: Self.shadowsocksRegionsEntryKey), !jsonEntry.isEmpty else {
            return .failure(RegionsError.unknownShadowsocksEntry)
        }
        guard let data = jsonEntry.data(using: .utf8) else {
            return .failure(RegionsError.unknownShadowsocksEntry)
        }
        let entry: [ShadowsocksRegionsResponse]
        do {
            entry = try JSONDecoder().decode([ShadowsocksRegionsResponse].self, from: data)
        } catch {
            log(error.localizedDescription)
            return .failure(RegionsError.emptyShadowsocksEntry)
        }
        guard !entry.isEmpty else {
            return .failure(RegionsError.emptyShadowsocksEntry)
        }
        return .success(entry)
    }

    // MARK: - Private

    private func store(key: String, value: String) {
        lock.withLock {
            userDefaults.set(value, forKey: key)
        }
    }

    private func retrieve(key: String) -> String? {
        lock.withLock {
            userDefaults.string(forKey: key)
        }
    }

    private func log(_ error: String) {
        if logErrorsEnabled {
            print("[\(Self.tag)]: \(error)")
        }
    }
}
