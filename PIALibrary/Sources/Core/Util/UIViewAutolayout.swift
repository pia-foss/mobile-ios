//
//  UIViewAutolayout.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 16/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
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
