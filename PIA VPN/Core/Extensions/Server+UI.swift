//
//  Server+UI.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/11/17.
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
import Alamofire
import UIKit

extension Server: CustomStringConvertible {
    func name(forStatus status: VPNStatus) -> String {
        
        let localizedName = name
        
        switch status {
//        case .connecting, .changingServer, .connected:
        case .connected:
            guard !isAutomatic else {
                let effectiveServer = Client.providers.vpnProvider.profileServer ?? Client.providers.serverProvider.targetServer
                let localizedName = effectiveServer.name
                return "\(name) (\(localizedName))"
            }
            return localizedName
            
        case .connecting:
            return L10n.Localizable.Dashboard.Vpn.connecting
        case .disconnecting:
            return L10n.Localizable.Dashboard.Vpn.disconnecting
        case .disconnected, .unknown:
            return localizedName
        }
    }
    
    func flagServer(forStatus status: VPNStatus) -> Server {
        switch status {
//        case .connecting, .changingServer, .connected:
        case .connecting, .connected:
            guard !isAutomatic else {
                return Client.providers.vpnProvider.profileServer ?? Client.providers.serverProvider.targetServer
            }
            return self
            
        default:
            return self
        }
    }

    public var description: String {
        return "\(name) [\(country)], \(hostname)"
    }
}

extension UIImageView {
    func setImage(fromServer server: Server) {
        let imageName = "flags/flag-\(server.country.lowercased())"
        guard let image = UIImage(named: imageName) else {
            return
        }
        self.image = image.withRenderingMode(.alwaysOriginal)
    }
}

extension UIButton {
    func setImage(fromServer server: Server) {
        let imageName = "flags/flag-\(server.country.lowercased())"
        guard let image = UIImage(named: imageName) else {
            return
        }
        let original = image.withRenderingMode(.alwaysOriginal)

        if !server.offline {
            self.setImage(original.image(alpha: 0.7), for: .normal)
        } else {
            self.setImage(original.image(alpha: 0.3), for: .normal)
        }
        self.setImage(image.withRenderingMode(.alwaysOriginal), for: .highlighted)
        
    }
}

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
