//
//  CoordinatesFinder.swift
//  PIA VPN
//  
//  Created by Jose Antonio Blaya Garcia on 27/05/2020.
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
import UIKit

class Coordinates {
    
    var latitude: Double
    var longitude: Double
    
    init(forServer server: String) {
    
        let coordinates = AppConstants.ServerCoordinates.coordinates[server]
        self.latitude = coordinates?["lat"] ?? AppConstants.ServerCoordinates.defaultCoordinates["lat"]!
        self.longitude = coordinates?["long"] ?? AppConstants.ServerCoordinates.defaultCoordinates["long"]!
        
    }
    
}
class CoordinatesFinder {
    
    private var worldMap: UIImageView!
    private var locationMeta: Coordinates!

    init(forServer server: String, usingMapImage imageView: UIImageView) {
        self.worldMap = imageView
        self.locationMeta = Coordinates(forServer: server)
    }
    
    private var markerRadius = 2.0

    // Top and bottom latitudes of map graphic
    private var topLat = 83.65
    private var bottomLat = -56.00
    
    // Left and right longitudes of map graphic
    private var leftLong = -168.12
    private var rightLong = -169.65

    // Top and bottom, Miller-projected
    private func topMiller() -> Float {
        return millerProjectLat(latitudeDeg: topLat)
    }
    private func bottomMiller() -> Float {
        return millerProjectLat(latitudeDeg: bottomLat)
    }

    private func degToRad(degrees: Float) -> Float {
        return degrees * Float.pi / 180.0
    }
    
    // Project latitude.  The map uses this projection:
    // https://en.wikipedia.org/wiki/Miller_cylindrical_projection
    private func millerProjectLat(latitudeDeg: Double) -> Float {
        return 1.25 * log2f(tan(Float.pi * 0.25 + 0.4 * degToRad(degrees: Float(latitudeDeg))))
    }

    private var locationX: Double {
    
        if(locationMeta == nil) {
            return -1.0
        }

        // Longitude is locationMeta.long -> range [-180, 180]
        var x = locationMeta.longitude
        // Adjust for actual left edge of graphic -> range [-168, 192]
        if(x < leftLong) {
            x += 360.0
        }
        // Map to [0, width]
        let mapWidth = Double(worldMap.frame.size.width)
        let a = x - leftLong
        let b = rightLong - leftLong
        return (a / (b + 360.0)) * mapWidth

    }
    
    private var locationY: Double {

        if(locationMeta == nil) {
            return -1.0
        }

        // Project the latitude -> range [-2.3034..., 2.3034...]
        let millerLat = millerProjectLat(latitudeDeg: locationMeta.latitude)
        
        // Map to the actual range shown by the map.  (If this point is outside
        // the map bound, it returns a negative value or a value greater than
        // height.)
        // Map to unit range -> [0, 1], where 0 is the bottom and 1 is the top
        let unitY = (millerLat - bottomMiller()) / (topMiller() - bottomMiller())
        
        // Flip and scale to height
        return (1.0-Double(unitY)) * Double(worldMap.frame.size.height)
        
    }
    
    private var mapPointX: Double {
        return round(locationX)
    }
  
    private var mapPointY: Double {
        return round(locationY)
    }
    
    private var showLocation: Bool {
        return mapPointX >= 0 && mapPointX < Double(worldMap.frame.size.width) &&
            mapPointY >= 0 && mapPointY < Double(worldMap.frame.size.height)
    }

      // We're aligning this dot to a non-directional image, so reflect X when RTL
      // mirror is on.
    private var x: Double {
        return mapPointX - markerRadius
    }
    
    private var y: Double {
        return mapPointY - markerRadius
    }
    
    private func innetDotRectInMap() -> CGRect {
        return CGRect(x: markerRadius,
                      y: markerRadius,
                      width: markerRadius*2,
                      height: markerRadius*2)
    }
    
    private func outerDotRectInMap() -> CGRect {
        return CGRect(x: locationX - markerRadius*2,
                      y: locationY - markerRadius*2,
                      width: markerRadius*4,
                      height: markerRadius*4)
    }
    
    /// Returns the dot pointing to the coordinates
    func dot() -> UIView {
        let outerDot = UIView(frame: self.outerDotRectInMap())
        outerDot.backgroundColor = UIColor.piaGreen.withAlphaComponent(0.2)
        outerDot.layer.cornerRadius = CGFloat(markerRadius*2)

        let innerDot = UIView(frame: self.innetDotRectInMap())
        innerDot.backgroundColor = UIColor.piaGreen
        innerDot.layer.cornerRadius = CGFloat(markerRadius)

        outerDot.addSubview(innerDot)
        return outerDot
    }

}
