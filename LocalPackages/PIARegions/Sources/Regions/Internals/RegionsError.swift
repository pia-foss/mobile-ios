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

internal enum RegionsError: Error, CustomStringConvertible {
    case invalidResponse
    case invalidSignature
    case noFallback
    case emptyVPNRegionsFallback
    case emptyShadowsocksFallback
    case invalidVPNRegionsJSON
    case invalidMetadataJSON
    case invalidJSONEncoding
    case invalidShadowsocksJSON
    case invalidRegionsResponse
    case noAvailableEndpoints
    case noCertificateForPinning
    case invalidHTTPClient
    case invalidURL(String)
    case httpError(Int)
    case invalidUTF8Response
    case unknownShadowsocksEntry
    case emptyShadowsocksEntry

    var description: String {
        switch self {
        case .invalidResponse: return "Invalid response"
        case .invalidSignature: return "Invalid signature on response"
        case .noFallback: return "No fallback configured"
        case .emptyVPNRegionsFallback: return "VPN regions JSON fallback is empty"
        case .emptyShadowsocksFallback: return "Shadowsocks regions JSON fallback is empty"
        case .invalidVPNRegionsJSON: return "Invalid VPN regions JSON"
        case .invalidMetadataJSON: return "Invalid metadata JSON"
        case .invalidJSONEncoding: return "Invalid JSON encoding"
        case .invalidShadowsocksJSON: return "Invalid Shadowsocks regions JSON"
        case .invalidRegionsResponse: return "Invalid regions response"
        case .noAvailableEndpoints: return "No available endpoints to perform the request"
        case .noCertificateForPinning: return "No certificate available for pinning"
        case .invalidHTTPClient: return "Invalid HTTP client"
        case .invalidURL(let endpoint): return "Invalid URL for endpoint: \(endpoint)"
        case .httpError(let code): return "HTTP \(code) \(HTTPURLResponse.localizedString(forStatusCode: code))"
        case .invalidUTF8Response: return "Unable to decode response as UTF-8"
        case .unknownShadowsocksEntry: return "Unknown Shadowsocks cache entry"
        case .emptyShadowsocksEntry: return "Shadowsocks cache entry is empty"
        }
    }
}
