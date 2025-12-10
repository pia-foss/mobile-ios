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

@available(tvOS 17.0, *)
extension PIAWebServices {

    func taskForConnectivityCheck(_ callback: ((ConnectivityStatus?, Error?) -> Void)?) {
        self.accountAPI.clientStatus(requestTimeoutMillis: 10000) { (information, errors) in
            DispatchQueue.main.async {
                if !errors.isEmpty {
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
    
    func submitDebugReport(_ shouldSendPersistedData: Bool, _ protocolLogs: String, _ callback: LibraryCallback<String>?) {
        csiProtocolInformationProvider.setProtocolLogs(protocolLogs: protocolLogs)
        self.csiAPI.send(shouldSendPersistedData: shouldSendPersistedData) { (reportIdentifier, errors) in
            if !errors.isEmpty {
                callback?(nil, ClientError.internetUnreachable)
                return
            }

            if let reportIdentifier = reportIdentifier {
                callback?(reportIdentifier, nil)
            } else {
                callback?(nil, ClientError.malformedResponseData)
            }
        }
    }
}
