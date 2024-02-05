//
//  RegionsFilterUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class RegionsFilterUseCaseMock: RegionsFilterUseCaseType {
    var getServersWithFilterCalled = false
    var getServersWithFilterCalledAttempt = 0
    var getServersWithFilterArgument:RegionsListFilter!
    var getServersWithFilterResult: [RegionsListFilter: [ServerType]] = [:]
    func getServers(with filter: RegionsListFilter) -> [ServerType] {
        getServersWithFilterCalled = true
        getServersWithFilterCalledAttempt += 1
        getServersWithFilterArgument = filter
        return getServersWithFilterResult[filter] ?? []
    }
    
    var saveToPrefiouslySearchedCalled = false
    var saveToPrefiouslySearchedCalledAttepmt = 0
    var saveToPrefiouslySearchedArgument: [ServerType]!
    func saveToPreviouslySearched(servers: [ServerType]) {
        saveToPrefiouslySearchedCalled = true
        saveToPrefiouslySearchedCalledAttepmt += 1
        saveToPrefiouslySearchedArgument = servers
    }
    
}
