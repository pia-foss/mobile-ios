//
//  Restylable.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/21/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/**
 Implemented by objects expected to handle a restyle
 request (typically after a `Notification.Name.ThemeDidChange` notification).
 */
public protocol Restylable {
    
    /**
     Updates dynamically styled views.
     */
    func viewShouldRestyle()
}
