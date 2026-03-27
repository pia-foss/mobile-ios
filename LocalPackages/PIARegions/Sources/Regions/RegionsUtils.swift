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

public enum RegionsUtils {

    /// Encodes a `VPNRegionsResponse` to a JSON string.
    public static func stringify(_ response: VPNRegionsResponse) throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        guard let json = String(data: data, encoding: .utf8) else {
            throw RegionsUtilsError.encodingFailed
        }
        return json
    }

    /// Decodes a `VPNRegionsResponse` from a JSON string.
    public static func parse(_ json: String) throws -> VPNRegionsResponse {
        guard let data = json.data(using: .utf8) else {
            throw RegionsUtilsError.invalidInput
        }
        let decoder = JSONDecoder()
        return try decoder.decode(VPNRegionsResponse.self, from: data)
    }

    internal static func isErrorStatusCode(_ code: Int) -> Bool {
        switch code {
        case 300...399:
            // Redirect response
            return true
        case 400...499:
            // Client error response
            return true
        case 500...599:
            // Server error response
            return true
        default:
            if code >= 600 {
                // Unknown error response
                return true
            }
            return false
        }
    }
}

public enum RegionsUtilsError: Error, Sendable {
    case encodingFailed
    case invalidInput
}
