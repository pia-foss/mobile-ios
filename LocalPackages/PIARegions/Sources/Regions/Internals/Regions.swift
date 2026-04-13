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

internal actor Regions: RegionsAPI {

    static let requestTimeoutMs = 6000
    static let publicKey =
        "-----BEGIN PUBLIC KEY-----\n" + "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzLYHwX5Ug/oUObZ5eH5P\n" + "rEwmfj4E/YEfSKLgFSsyRGGsVmmjiXBmSbX2s3xbj/ofuvYtkMkP/VPFHy9E/8ox\n" + "Y+cRjPzydxz46LPY7jpEw1NHZjOyTeUero5e1nkLhiQqO/cMVYmUnuVcuFfZyZvc\n" + "8Apx5fBrIp2oWpF/G9tpUZfUUJaaHiXDtuYP8o8VhYtyjuUu3h7rkQFoMxvuoOFH\n" + "6nkc0VQmBsHvCfq4T9v8gyiBtQRy543leapTBMT34mxVIQ4ReGLPVit/6sNLoGLb\n" + "gSnGe9Bk/a5V/5vlqeemWF0hgoRtUxMtU1hFbe7e8tSq1j+mu0SHMyKHiHd+OsmU\n" + "IQIDAQAB\n" + "-----END PUBLIC KEY-----"

    private let userAgent: String
    private let vpnRegionsRequestPath: String
    private let shadowsocksRegionsRequestPath: String
    private let metadataRequestPath: String
    private let regionJSONFallback: RegionJSONFallback?
    private let endpointsProvider: any RegionEndpointProvider
    private let certificate: String?
    private let inMemory: any RegionsCacheDataSource
    private let persistence: any RegionsCacheDataSource

    init(
        userAgent: String,
        vpnRegionsRequestPath: String,
        shadowsocksRegionsRequestPath: String,
        metadataRequestPath: String,
        regionJSONFallback: RegionJSONFallback?,
        endpointsProvider: any RegionEndpointProvider,
        certificate: String?,
        inMemory: any RegionsCacheDataSource,
        persistence: any RegionsCacheDataSource
    ) {
        self.userAgent = userAgent
        self.vpnRegionsRequestPath = vpnRegionsRequestPath
        self.shadowsocksRegionsRequestPath = shadowsocksRegionsRequestPath
        self.metadataRequestPath = metadataRequestPath
        self.regionJSONFallback = regionJSONFallback
        self.endpointsProvider = endpointsProvider
        self.certificate = certificate
        self.inMemory = inMemory
        self.persistence = persistence
    }

    // MARK: - RegionsAPI

    func fetchVPNRegions(locale: String) async -> (VPNRegionsResponse?, Error?) {
        let result = await requestVPNRegions(locale: locale)
        switch result {
        case .success(let vpnRegionsResponse):
            inMemory.saveVPNRegions(locale: locale, response: vpnRegionsResponse)
            persistence.saveVPNRegions(locale: locale, response: vpnRegionsResponse)
            return (vpnRegionsResponse, nil)
        case .failure(let decodeVPNRegionsFailure):
            let knownVPNRegionsResponse: VPNRegionsResponse? = {
                if let cached = try? inMemory.getVPNRegions(locale: locale).get() {
                    return cached
                }
                if let persisted = try? persistence.getVPNRegions(locale: locale).get() {
                    return persisted
                }
                return nil
            }()
            if let response = knownVPNRegionsResponse {
                return (response, nil)
            }
            if let fallback = try? await fallbackVPNRegionsResponseIfPossible(locale: locale).get() {
                return (fallback, nil)
            }
            return (nil, decodeVPNRegionsFailure)
        }
    }

    func fetchShadowsocksRegions(locale: String) async -> ([ShadowsocksRegionsResponse], Error?) {
        let result = await requestShadowsocksRegions(locale: locale)
        switch result {
        case .success(let shadowsocksRegionsResponse):
            inMemory.saveShadowsocksRegions(locale: locale, response: shadowsocksRegionsResponse)
            persistence.saveShadowsocksRegions(locale: locale, response: shadowsocksRegionsResponse)
            return (shadowsocksRegionsResponse, nil)
        case .failure(let decodeShadowsocksRegionsFailure):
            let knownShadowsocksRegionsResponse: [ShadowsocksRegionsResponse]? = {
                if let cached = try? inMemory.getShadowsocksRegions(locale: locale).get() {
                    return cached
                }
                if let persisted = try? persistence.getShadowsocksRegions(locale: locale).get() {
                    return persisted
                }
                return nil
            }()
            if let response = knownShadowsocksRegionsResponse {
                return (response, nil)
            }
            if let fallback = try? await fallbackShadowsocksRegionsResponseIfPossible(locale: locale).get() {
                return (fallback, nil)
            }
            return ([], decodeShadowsocksRegionsFailure)
        }
    }

    // MARK: - Private

    // Fire metadata and VPN regions requests concurrently — cuts latency roughly in half.
    private func requestVPNRegions(locale: String) async -> Result<VPNRegionsResponse, Error> {
        async let metadataRequest = performRequest(
            endpoints: endpointsProvider.regionEndpoints(),
            requestPath: metadataRequestPath
        )
        async let vpnRegionsRequest = performRequest(
            endpoints: endpointsProvider.regionEndpoints(),
            requestPath: vpnRegionsRequestPath
        )

        let (metadataResponse, vpnResponse) = await (metadataRequest, vpnRegionsRequest)

        let metadataResult = processResponseIntoMessageWithKeyAndVerifyIntegrity(
            response: try? metadataResponse.get()
        )
        let vpnRegionsResult = processResponseIntoMessageWithKeyAndVerifyIntegrity(
            response: try? vpnResponse.get()
        )

        return await decodeVPNRegions(
            metadataJSON: try? metadataResult.get(),
            vpnRegionsJSON: try? vpnRegionsResult.get(),
            locale: locale
        )
    }

    // Fire all three requests concurrently — metadata, VPN regions, and Shadowsocks in parallel.
    private func requestShadowsocksRegions(locale: String) async -> Result<[ShadowsocksRegionsResponse], Error> {
        async let metadataRequest = performRequest(
            endpoints: endpointsProvider.regionEndpoints(),
            requestPath: metadataRequestPath
        )
        async let vpnRegionsRequest = performRequest(
            endpoints: endpointsProvider.regionEndpoints(),
            requestPath: vpnRegionsRequestPath
        )
        async let shadowsocksRequest = performRequest(
            endpoints: endpointsProvider.regionEndpoints(),
            requestPath: shadowsocksRegionsRequestPath
        )

        let (metadataResponse, vpnResponse, shadowsocksResponse) = await (metadataRequest, vpnRegionsRequest, shadowsocksRequest)

        let metadataResult = processResponseIntoMessageWithKeyAndVerifyIntegrity(
            response: try? metadataResponse.get()
        )
        let vpnRegionsResult = processResponseIntoMessageWithKeyAndVerifyIntegrity(
            response: try? vpnResponse.get()
        )
        let shadowsocksResult = processResponseIntoMessageWithKeyAndVerifyIntegrity(
            response: try? shadowsocksResponse.get()
        )

        let vpnRegionsResponse = await decodeVPNRegions(
            metadataJSON: try? metadataResult.get(),
            vpnRegionsJSON: try? vpnRegionsResult.get(),
            locale: locale
        )

        return await decodeShadowsocksRegions(
            vpnRegionsResponse: try? vpnRegionsResponse.get(),
            shadowsocksRegionsJSON: try? shadowsocksResult.get()
        )
    }

    private nonisolated func processResponseIntoMessageWithKeyAndVerifyIntegrity(
        response: String?
    ) -> Result<String, Error> {
        guard let response else {
            return .failure(RegionsError.invalidResponse)
        }

        let (message, key) = processResponseIntoMessageAndKey(response)
        if MessageVerificator.verifyMessage(message, key: key) {
            return .success(message)
        }
        return .failure(RegionsError.invalidSignature)
    }

    private nonisolated func processResponseIntoMessageAndKey(_ response: String) -> (message: String, key: String) {
        let parts = response.components(separatedBy: "\n\n")
        let message = parts.first ?? ""
        let key = parts.last ?? ""
        return (message, key)
    }

    private func fallbackVPNRegionsResponseIfPossible(locale: String) async -> Result<VPNRegionsResponse, Error> {
        guard let fallback = regionJSONFallback else {
            return .failure(RegionsError.noFallback)
        }
        guard !fallback.vpnRegionsJSON.isEmpty else {
            return .failure(RegionsError.emptyVPNRegionsFallback)
        }
        return await decodeVPNRegions(
            metadataJSON: fallback.metadataJSON,
            vpnRegionsJSON: fallback.vpnRegionsJSON,
            locale: locale
        )
    }

    private func fallbackShadowsocksRegionsResponseIfPossible(locale: String) async -> Result<[ShadowsocksRegionsResponse], Error> {
        let fallbackVpnResult = await fallbackVPNRegionsResponseIfPossible(locale: locale)
        guard case .success = fallbackVpnResult else {
            return .failure(RegionsError.noFallback)
        }
        guard let fallback = regionJSONFallback else {
            return .failure(RegionsError.noFallback)
        }
        guard !fallback.shadowsocksRegionsJSON.isEmpty else {
            return .failure(RegionsError.emptyShadowsocksFallback)
        }
        return await decodeShadowsocksRegions(
            vpnRegionsResponse: try? fallbackVpnResult.get(),
            shadowsocksRegionsJSON: fallback.shadowsocksRegionsJSON
        )
    }

    // JSON decoding + O(n) translation lookups are CPU-bound. @concurrent pushes this
    // off the actor's serial executor onto the cooperative thread pool.
    @concurrent
    private nonisolated func decodeVPNRegions(
        metadataJSON: String?,
        vpnRegionsJSON: String?,
        locale: String
    ) async -> Result<VPNRegionsResponse, Error> {
        guard let vpnRegionsJSON, !vpnRegionsJSON.isEmpty else {
            return .failure(RegionsError.invalidVPNRegionsJSON)
        }
        guard let metadataJSON, !metadataJSON.isEmpty else {
            return .failure(RegionsError.invalidMetadataJSON)
        }

        let decoder = JSONDecoder()
        let vpnRegionsResponse: VPNRegionsResponse
        let translationsGeoResponse: TranslationsGeoResponse

        do {
            guard let vpnData = vpnRegionsJSON.data(using: .utf8),
                let metaData = metadataJSON.data(using: .utf8)
            else {
                return .failure(RegionsError.invalidJSONEncoding)
            }
            vpnRegionsResponse = try decoder.decode(VPNRegionsResponse.self, from: vpnData)
            translationsGeoResponse = try decoder.decode(TranslationsGeoResponse.self, from: metaData)
        } catch {
            return .failure(error)
        }

        var localizedRegions: [VPNRegionsResponse.Region] = []
        for region in vpnRegionsResponse.regions {
            guard let regionTranslations = translationsForVpnRegion(region.name, translationsGeoResponse: translationsGeoResponse) else {
                localizedRegions.append(region)
                continue
            }

            let translatedName = vpnRegionTranslationForLocale(locale, regionTranslations: regionTranslations)

            var updatedRegion = region
            if let name = translatedName, !name.isEmpty {
                updatedRegion.name = name
            }

            if let coordinates = coordinatesForRegionId(region.id, translationsGeoResponse: translationsGeoResponse) {
                updatedRegion.latitude = coordinates.latitude
                updatedRegion.longitude = coordinates.longitude
            }

            localizedRegions.append(updatedRegion)
        }

        var result = vpnRegionsResponse
        result.regions = localizedRegions
        return .success(result)
    }

    @concurrent
    private nonisolated func decodeShadowsocksRegions(
        vpnRegionsResponse: VPNRegionsResponse?,
        shadowsocksRegionsJSON: String?
    ) async -> Result<[ShadowsocksRegionsResponse], Error> {
        guard let shadowsocksRegionsJSON, !shadowsocksRegionsJSON.isEmpty else {
            return .failure(RegionsError.invalidShadowsocksJSON)
        }
        guard let vpnRegionsResponse else {
            return .failure(RegionsError.invalidRegionsResponse)
        }

        let decoder = JSONDecoder()
        let shadowsocksRegionsResponse: [ShadowsocksRegionsResponse]
        do {
            guard let data = shadowsocksRegionsJSON.data(using: .utf8) else {
                return .failure(RegionsError.invalidJSONEncoding)
            }
            shadowsocksRegionsResponse = try decoder.decode([ShadowsocksRegionsResponse].self, from: data)
        } catch {
            return .failure(error)
        }

        var localizedRegions: [ShadowsocksRegionsResponse] = []
        for region in shadowsocksRegionsResponse {
            if let translation = shadowsocksRegionTranslation(region.region, vpnRegionsResponse: vpnRegionsResponse),
                let iso = shadowsocksRegionIso(region.region, vpnRegionsResponse: vpnRegionsResponse)
            {
                var updated = region
                updated.iso = iso
                updated.region = translation
                localizedRegions.append(updated)
            }
        }
        return .success(localizedRegions)
    }

    private nonisolated func translationsForVpnRegion(
        _ region: String,
        translationsGeoResponse: TranslationsGeoResponse
    ) -> [String: String]? {
        for (regionName, regionTranslations) in translationsGeoResponse.translations {
            if regionName.lowercased() == region.lowercased() {
                return regionTranslations
            }
        }
        return nil
    }

    private nonisolated func vpnRegionTranslationForLocale(
        _ targetLocale: String,
        regionTranslations: [String: String]
    ) -> String? {
        for (locale, translation) in regionTranslations {
            if locale.lowercased() == targetLocale.lowercased() {
                return translation
            }
            let localeLanguage =
                targetLocale.contains("-")
                ? String(targetLocale.split(separator: "-").first ?? Substring(targetLocale))
                : targetLocale
            if locale.lowercased().hasPrefix(localeLanguage.lowercased()) {
                return translation
            }
        }
        return nil
    }

    private nonisolated func shadowsocksRegionTranslation(
        _ shadowsocksRegion: String,
        vpnRegionsResponse: VPNRegionsResponse
    ) -> String? {
        for region in vpnRegionsResponse.regions {
            if region.id.lowercased() == shadowsocksRegion.lowercased() {
                return region.name
            }
        }
        return nil
    }

    private nonisolated func shadowsocksRegionIso(
        _ shadowsocksRegion: String,
        vpnRegionsResponse: VPNRegionsResponse
    ) -> String? {
        for region in vpnRegionsResponse.regions {
            if region.id.lowercased() == shadowsocksRegion.lowercased() {
                return region.country
            }
        }
        return nil
    }

    private nonisolated func coordinatesForRegionId(
        _ targetRegionId: String,
        translationsGeoResponse: TranslationsGeoResponse
    ) -> (latitude: String, longitude: String)? {
        for (regionId, coordinates) in translationsGeoResponse.gps {
            if regionId.lowercased() == targetRegionId.lowercased(), coordinates.count >= 2 {
                return (coordinates[0], coordinates[1])
            }
        }
        return nil
    }

    private func performRequest(
        endpoints: [RegionEndpoint],
        requestPath: String
    ) async -> Result<String, Error> {
        if endpoints.isEmpty {
            return .failure(RegionsError.noAvailableEndpoints)
        }

        var lastError: Error = RegionsError.noAvailableEndpoints

        for endpoint in endpoints {
            // Cooperative cancellation: stop trying further endpoints if the task was cancelled.
            guard !Task.isCancelled else { break }

            if endpoint.usePinnedCertificate && (certificate?.isEmpty ?? true) {
                lastError = RegionsError.noCertificateForPinning
                continue
            }

            let (session, clientError): (URLSession?, Error?)
            if endpoint.usePinnedCertificate, let cert = certificate, let cn = endpoint.certificateCommonName {
                (session, clientError) = RegionHttpClient.client(
                    certificate: cert,
                    pinnedEndpoint: (hostname: endpoint.endpoint, commonName: cn)
                )
            } else {
                (session, clientError) = RegionHttpClient.client()
            }

            if let clientError {
                lastError = clientError
                continue
            }

            guard let session else {
                lastError = RegionsError.invalidHTTPClient
                continue
            }

            guard let url = URL(string: "https://\(endpoint.endpoint)\(requestPath)") else {
                lastError = RegionsError.invalidURL(endpoint.endpoint)
                session.invalidateAndCancel()
                continue
            }

            var request = URLRequest(url: url)
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

            do {
                let (data, response) = try await session.data(for: request)
                session.finishTasksAndInvalidate()
                if let httpResponse = response as? HTTPURLResponse,
                    RegionsUtils.isErrorStatusCode(httpResponse.statusCode)
                {
                    lastError = RegionsError.httpError(httpResponse.statusCode)
                    continue
                }
                guard let text = String(data: data, encoding: .utf8) else {
                    lastError = RegionsError.invalidUTF8Response
                    continue
                }
                return .success(text)
            } catch {
                session.invalidateAndCancel()
                lastError = error
                continue
            }
        }

        return .failure(lastError)
    }
}
