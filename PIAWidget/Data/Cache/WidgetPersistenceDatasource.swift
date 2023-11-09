//
//  WidgetPersistenceDatasource.swift
//  PIAWidgetExtension
//
//  Created by Juan Docal on 2022-09-28.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation

internal protocol WidgetPersistenceDatasource {
    func getIsVPNConnected() -> Bool
    func getIsTrustedNetwork() -> Bool
    func getVpnProtocol() -> String
    func getVpnPort() -> String
    func getVpnSocket() -> String
}
