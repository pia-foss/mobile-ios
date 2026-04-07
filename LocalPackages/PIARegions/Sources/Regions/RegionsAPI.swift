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


public enum RegionsProtocol: String, Sendable {
    case openVPNTCP = "ovpntcp"
    case openVPNUDP = "ovpnudp"
    case wireGuard = "wg"
    case meta = "meta"
}

/// Protocol defining the API offered by the Regions module.
public protocol RegionsAPI: Sendable {

    /// Fetch all VPN regions information.
    ///
    /// - Parameter locale: Regions locale. If unknown defaults to en-us.
    /// - Returns: Tuple of the response and an optional error.
    func fetchVPNRegions(locale: String) async -> (VPNRegionsResponse?, Error?)

    /// Fetch all Shadowsocks regions information.
    ///
    /// - Parameter locale: Regions locale. If unknown defaults to en-us.
    /// - Returns: Tuple of the response list and an optional error.
    func fetchShadowsocksRegions(locale: String) async -> ([ShadowsocksRegionsResponse], Error?)
}

/// Protocol defining the client's endpoint provider.
public protocol RegionEndpointProvider: Sendable {

    /// Returns the list of endpoints to try when performing a request. Order is relevant.
    func regionEndpoints() -> [RegionEndpoint]
}

/// Data structure defining the endpoints data needed when performing a request.
public struct RegionEndpoint: Sendable {
    public let endpoint: String
    public let isProxy: Bool
    public let usePinnedCertificate: Bool
    public let certificateCommonName: String?

    public init(
        endpoint: String,
        isProxy: Bool,
        usePinnedCertificate: Bool = false,
        certificateCommonName: String? = nil
    ) {
        self.endpoint = endpoint
        self.isProxy = isProxy
        self.usePinnedCertificate = usePinnedCertificate
        self.certificateCommonName = certificateCommonName
    }
}

/// Data structure defining the required JSON information for a successful fallback response.
public struct RegionJSONFallback: Sendable {
    public let vpnRegionsJSON: String
    public let shadowsocksRegionsJSON: String
    public let metadataJSON: String

    public init(vpnRegionsJSON: String, shadowsocksRegionsJSON: String, metadataJSON: String) {
        self.vpnRegionsJSON = vpnRegionsJSON
        self.shadowsocksRegionsJSON = shadowsocksRegionsJSON
        self.metadataJSON = metadataJSON
    }
}

/// Builder class responsible for creating an instance conforming to `RegionsAPI`.
public final class RegionsBuilder: Sendable {
    private let endpointsProvider: (any RegionEndpointProvider)?
    private let certificate: String?
    private let userAgent: String?
    private let vpnRegionsRequestPath: String?
    private let shadowsocksRegionsRequestPath: String?
    private let metadataRequestPath: String?
    private let regionJSONFallback: RegionJSONFallback?
    private let persistencePreferenceName: String?
    private let logErrors: Bool

    public init() {
        self.endpointsProvider = nil
        self.certificate = nil
        self.userAgent = nil
        self.vpnRegionsRequestPath = nil
        self.shadowsocksRegionsRequestPath = nil
        self.metadataRequestPath = nil
        self.regionJSONFallback = nil
        self.persistencePreferenceName = nil
        self.logErrors = false
    }

    private init(
        endpointsProvider: (any RegionEndpointProvider)?,
        certificate: String?,
        userAgent: String?,
        vpnRegionsRequestPath: String?,
        shadowsocksRegionsRequestPath: String?,
        metadataRequestPath: String?,
        regionJSONFallback: RegionJSONFallback?,
        persistencePreferenceName: String?,
        logErrors: Bool
    ) {
        self.endpointsProvider = endpointsProvider
        self.certificate = certificate
        self.userAgent = userAgent
        self.vpnRegionsRequestPath = vpnRegionsRequestPath
        self.shadowsocksRegionsRequestPath = shadowsocksRegionsRequestPath
        self.metadataRequestPath = metadataRequestPath
        self.regionJSONFallback = regionJSONFallback
        self.persistencePreferenceName = persistencePreferenceName
        self.logErrors = logErrors
    }

    /// Sets the endpoints provider. Required.
    public func setEndpointProvider(_ endpointsProvider: any RegionEndpointProvider) -> RegionsBuilder {
        RegionsBuilder(
            endpointsProvider: endpointsProvider,
            certificate: certificate,
            userAgent: userAgent,
            vpnRegionsRequestPath: vpnRegionsRequestPath,
            shadowsocksRegionsRequestPath: shadowsocksRegionsRequestPath,
            metadataRequestPath: metadataRequestPath,
            regionJSONFallback: regionJSONFallback,
            persistencePreferenceName: persistencePreferenceName,
            logErrors: logErrors
        )
    }

    /// Sets the certificate to use when an endpoint has pinning enabled. Optional.
    public func setCertificate(_ certificate: String?) -> RegionsBuilder {
        RegionsBuilder(
            endpointsProvider: endpointsProvider,
            certificate: certificate,
            userAgent: userAgent,
            vpnRegionsRequestPath: vpnRegionsRequestPath,
            shadowsocksRegionsRequestPath: shadowsocksRegionsRequestPath,
            metadataRequestPath: metadataRequestPath,
            regionJSONFallback: regionJSONFallback,
            persistencePreferenceName: persistencePreferenceName,
            logErrors: logErrors
        )
    }

    /// Sets the User-Agent value to be used in requests.
    public func setUserAgent(_ userAgent: String) -> RegionsBuilder {
        RegionsBuilder(
            endpointsProvider: endpointsProvider,
            certificate: certificate,
            userAgent: userAgent,
            vpnRegionsRequestPath: vpnRegionsRequestPath,
            shadowsocksRegionsRequestPath: shadowsocksRegionsRequestPath,
            metadataRequestPath: metadataRequestPath,
            regionJSONFallback: regionJSONFallback,
            persistencePreferenceName: persistencePreferenceName,
            logErrors: logErrors
        )
    }

    /// Sets the path used by requests retrieving the VPN regions list.
    public func setVPNRegionsRequestPath(_ vpnRegionsRequestPath: String) -> RegionsBuilder {
        RegionsBuilder(
            endpointsProvider: endpointsProvider,
            certificate: certificate,
            userAgent: userAgent,
            vpnRegionsRequestPath: vpnRegionsRequestPath,
            shadowsocksRegionsRequestPath: shadowsocksRegionsRequestPath,
            metadataRequestPath: metadataRequestPath,
            regionJSONFallback: regionJSONFallback,
            persistencePreferenceName: persistencePreferenceName,
            logErrors: logErrors
        )
    }

    /// Sets the path used by requests retrieving the Shadowsocks regions list.
    public func setShadowsocksRegionsRequestPath(_ shadowsocksRegionsRequestPath: String) -> RegionsBuilder {
        RegionsBuilder(
            endpointsProvider: endpointsProvider,
            certificate: certificate,
            userAgent: userAgent,
            vpnRegionsRequestPath: vpnRegionsRequestPath,
            shadowsocksRegionsRequestPath: shadowsocksRegionsRequestPath,
            metadataRequestPath: metadataRequestPath,
            regionJSONFallback: regionJSONFallback,
            persistencePreferenceName: persistencePreferenceName,
            logErrors: logErrors
        )
    }

    /// Sets the path used by requests retrieving metadata.
    public func setMetadataRequestPath(_ metadataRequestPath: String) -> RegionsBuilder {
        RegionsBuilder(
            endpointsProvider: endpointsProvider,
            certificate: certificate,
            userAgent: userAgent,
            vpnRegionsRequestPath: vpnRegionsRequestPath,
            shadowsocksRegionsRequestPath: shadowsocksRegionsRequestPath,
            metadataRequestPath: metadataRequestPath,
            regionJSONFallback: regionJSONFallback,
            persistencePreferenceName: persistencePreferenceName,
            logErrors: logErrors
        )
    }

    /// Sets the fallback JSON object used when requests, cache, and persistence all fail.
    public func setRegionJSONFallback(_ regionJSONFallback: RegionJSONFallback) -> RegionsBuilder {
        RegionsBuilder(
            endpointsProvider: endpointsProvider,
            certificate: certificate,
            userAgent: userAgent,
            vpnRegionsRequestPath: vpnRegionsRequestPath,
            shadowsocksRegionsRequestPath: shadowsocksRegionsRequestPath,
            metadataRequestPath: metadataRequestPath,
            regionJSONFallback: regionJSONFallback,
            persistencePreferenceName: persistencePreferenceName,
            logErrors: logErrors
        )
    }

    /// Sets the name used by the persistence framework. Optional.
    public func setPersistencePreferenceName(_ name: String?) -> RegionsBuilder {
        let trimmed = name.flatMap { $0.trimmingCharacters(in: .whitespaces).isEmpty ? nil : $0.trimmingCharacters(in: .whitespaces) }
        return RegionsBuilder(
            endpointsProvider: endpointsProvider,
            certificate: certificate,
            userAgent: userAgent,
            vpnRegionsRequestPath: vpnRegionsRequestPath,
            shadowsocksRegionsRequestPath: shadowsocksRegionsRequestPath,
            metadataRequestPath: metadataRequestPath,
            regionJSONFallback: regionJSONFallback,
            persistencePreferenceName: trimmed,
            logErrors: logErrors
        )
    }

    /// Enables internal error logging. `false` by default.
    public func setLogErrors(_ logErrors: Bool) -> RegionsBuilder {
        RegionsBuilder(
            endpointsProvider: endpointsProvider,
            certificate: certificate,
            userAgent: userAgent,
            vpnRegionsRequestPath: vpnRegionsRequestPath,
            shadowsocksRegionsRequestPath: shadowsocksRegionsRequestPath,
            metadataRequestPath: metadataRequestPath,
            regionJSONFallback: regionJSONFallback,
            persistencePreferenceName: persistencePreferenceName,
            logErrors: logErrors
        )
    }

    /// Builds and returns a `RegionsAPI` instance.
    ///
    /// - Throws: If any required parameter is missing.
    public func build() throws -> any RegionsAPI {
        guard let endpointsProvider else {
            throw RegionsBuilderError.missingEndpointsProvider
        }
        guard let userAgent else {
            throw RegionsBuilderError.missingUserAgent
        }
        guard let vpnRegionsRequestPath else {
            throw RegionsBuilderError.missingVPNRegionsRequestPath
        }
        guard let shadowsocksRegionsRequestPath else {
            throw RegionsBuilderError.missingShadowsocksRegionsRequestPath
        }
        guard let metadataRequestPath else {
            throw RegionsBuilderError.missingMetadataRequestPath
        }

        let factory = RegionsDataSourceFactoryImpl(logErrors: logErrors)
        let inMemory = factory.newInMemoryDataSource()
        let persistence = factory.newPersistenceRegionsDataSource(preferenceName: persistencePreferenceName)

        return Regions(
            userAgent: userAgent,
            vpnRegionsRequestPath: vpnRegionsRequestPath,
            shadowsocksRegionsRequestPath: shadowsocksRegionsRequestPath,
            metadataRequestPath: metadataRequestPath,
            regionJSONFallback: regionJSONFallback,
            endpointsProvider: endpointsProvider,
            certificate: certificate,
            inMemory: inMemory,
            persistence: persistence
        )
    }
}

public enum RegionsBuilderError: Error, Sendable {
    case missingEndpointsProvider
    case missingUserAgent
    case missingVPNRegionsRequestPath
    case missingShadowsocksRegionsRequestPath
    case missingMetadataRequestPath
}
