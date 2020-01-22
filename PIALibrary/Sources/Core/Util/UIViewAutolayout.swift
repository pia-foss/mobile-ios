//
//  UIViewAutolayout.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 16/01/2019.
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

import UIKit 

public extension UIView {
    
    public func addConstaintsToSuperview(leadingOffset: CGFloat, trailingOffset: CGFloat, topOffset: CGFloat, bottomOffset: CGFloat) {
        
        guard superview != nil else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        leadingAnchor.constraint(equalTo: superview!.leadingAnchor,
                                 constant: leadingOffset).isActive = true
        trailingAnchor.constraint(equalTo: superview!.trailingAnchor,
                                  constant: trailingOffset).isActive = true
        
        topAnchor.constraint(equalTo: superview!.topAnchor,
                             constant: topOffset).isActive = true
        bottomAnchor.constraint(equalTo: superview!.bottomAnchor,
                                constant: bottomOffset).isActive = true
    }
    
}
