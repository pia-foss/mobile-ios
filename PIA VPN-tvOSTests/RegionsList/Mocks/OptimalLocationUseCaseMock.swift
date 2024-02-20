//
//  OptimalLocationUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/20/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine
@testable import PIA_VPN_tvOS


class OptimalLocationUseCaseMock: OptimalLocationUseCaseType {
    
    var optimalLocation: ServerType = ServerMock()
    
    var targetLocationForOptimalLocation: CurrentValueSubject<ServerType?, Never> = CurrentValueSubject(nil)
    
    func getTargetLocaionForOptimalLocation() -> AnyPublisher<ServerType?, Never> {
        return targetLocationForOptimalLocation.eraseToAnyPublisher()
    }
    
    
}
