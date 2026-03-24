//
//  VPNStatusMonitorType.swift
//  PIALibrary
//
//  Created by Mario on 24/03/2026.
//  Copyright © 2026 Private Internet Access, Inc.
//

import Combine
import Foundation

public protocol VPNStatusMonitorType {
    func getStatus() -> AnyPublisher<VPNStatus, Never>
}
