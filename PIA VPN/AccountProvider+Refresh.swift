//
//  AccountProvider.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/16/17.
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
import PIALibrary
import SwiftyBeaver

private let log = SwiftyBeaver.self

extension AccountProvider {
    
    func retrieveAccount() {
        
        guard self.isLoggedIn else {
            return
        }

        accountInformation({ (info, error) in
            guard let error = error as? ClientError else {
                return
            }
            guard self.isLoggedIn else {
                return
            }
            
            if (error == .unauthorized) {
                log.error("Account: Failed to retrieve the account info, user is unauthorized. Logging out...")
                self.logout(nil)
                Macros.postNotification(.PIAUnauthorized)
            }
        })
    }
    
    func refreshAndLogoutUnauthorized() {
        
        guard self.isLoggedIn else {
            return
        }
        
        refreshAccount()
        
    }
    
    private func refreshAccount() {

        refreshAccountInfo( { (info, error) in
            guard let error = error as? ClientError else {
                return
            }
            guard self.isLoggedIn else {
                return
            }
            
            if (error == .unauthorized) {
                log.error("Account: Failed to refresh account info, user is unauthorized. Logging out...")
                self.logout(nil)
            }
        })

    }
}
