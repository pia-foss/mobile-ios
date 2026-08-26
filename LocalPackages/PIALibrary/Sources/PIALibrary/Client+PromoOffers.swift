//
//  Client+PromoOffers.swift
//  PIALibrary
//
//  Copyright © 2026 Private Internet Access, Inc.
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
import PIAAccount

extension Client {
    /// The configured, environment-aware, certificate-pinned native account API.
    ///
    /// Reuses the instance already built by `PIAWebServices`; if the current web services are a
    /// mock (tests), a fresh client is built with the same configuration. Exposed publicly so the
    /// app target can reach the unauthenticated Apple promotional-offer endpoints.
    public static var nativeAccountAPI: PIAAccountAPI {
        if let webServices = webServices as? PIAWebServices {
            return webServices.nativeAccountAPI
        }
        return makeNativeAccountAPI()
    }

    private static func makeNativeAccountAPI() -> PIAAccountAPI {
        let nativeEndpointProvider: PIAAccountEndpointProvider =
            switch Client.environment {
            case .staging:
                PIANativeAccountStagingEndpointProvider()
            case .production:
                PIANativeAccountEndpointProvider()
            }

        var builder = PIAAccountBuilder()
        builder.setEndpointProvider(nativeEndpointProvider)
        builder.setCertificate(Client.configuration.rsa4096Certificate)
        builder.setUserAgent(PIAWebServices.userAgent)
        return try! builder.build()
    }
}
