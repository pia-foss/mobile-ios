//
//  PIAWebServices+Ephemeral.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/14/17.
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
import Gloss

extension PIAWebServices {

    func taskForConnectivityCheck(_ callback: ((ConnectivityStatus?, Error?) -> Void)?) {
                
        self.accountAPI.clientStatus { (information, error) in
            DispatchQueue.main.async {
                if let _ = error {
                    callback?(nil, ClientError.internetUnreachable)
                    return
                }

                if let information = information {
                    callback?(ConnectivityStatus(ipAddress: information.ip, isVPN: information.connected), nil)
                } else {
                    callback?(nil, ClientError.malformedResponseData)
                }
            }
        }
        
    }
    
    func submitDebugLog(_ log: DebugLog, _ callback: SuccessLibraryCallback?) {
        let data = log.serialized()
        guard let bigdata = String(data: data, encoding: .isoLatin1)?.urlEncoded() else {
            callback?(nil)
            return
        }

        let body = "bigdata=\(bigdata)"
        let url = VPNEndpoint.debugLog.url

        let config: URLSessionConfiguration = .ephemeral
        config.timeoutIntervalForRequest = Double(accessedConfiguration.webTimeout) / 1000.0
        config.timeoutIntervalForResource = Double(accessedConfiguration.webTimeout) / 1000.0
        let session = URLSession(configuration: config)

        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: Double(accessedConfiguration.webTimeout) / 1000.0
        )
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .isoLatin1)

        session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    callback?(ClientError.malformedResponseData)
                    return
                }
                guard (httpResponse.statusCode == 200) else {
                    callback?(ClientError.unexpectedReply)
                    return
                }
                callback?(nil)
            }
        }.resume()
    }
}

//private extension String {
//    private static let urlEncodedSet = CharacterSet(charactersIn: "!'();:@&=+$,/?%#[]")
//
//    func urlEncoded() -> String? {
//        return addingPercentEncoding(withAllowedCharacters: String.urlEncodedSet)
//    }
//}
