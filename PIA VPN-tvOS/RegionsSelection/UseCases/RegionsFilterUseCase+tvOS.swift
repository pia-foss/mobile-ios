//
//  RegionsFilterUseCase+tvOS.swift
//  PIA VPN-tvOS
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
import PIADashboard
import PIADedicatedIP
import PIAFavorites
import PIALibrary
import PIARegionListDomain

extension RegionsFilterUseCase {
    convenience init(
        serversUseCase: RegionsListUseCaseType,
        favoritesUseCase: FavoriteRegionUseCaseType,
        searchedRegionsAvailability: SearchedRegionsAvailabilityType,
        getDedicatedIpUseCase: GetDedicatedIpUseCaseType
    ) {
        self.init(
            serversUseCase: serversUseCase,
            favoritesUseCase: favoritesUseCase,
            searchedRegionsAvailability: searchedRegionsAvailability,
            automaticServer: SelectedServerUseCase.automaticServer(),
            isDedicatedIp: getDedicatedIpUseCase.isDedicatedIp,
            currentVPNType: { Client.providers.vpnProvider.currentVPNType }
        )
    }
}
