//
//  Notification+UI.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 12/30/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

// TODO: make this (mostly) work for both iOS and macOS
// e.g. use Macros always, which in turn may return UIColor/NSColor

public extension Notification.Name {
    
    // MARK: UI
    
    /// Posted following a theme switch.
    public static let PIAThemeDidChange = Notification.Name("PIAThemeDidChange")
    
    /// Reload the tiles.
    public static let PIATilesDidChange = Notification.Name("PIATilesDidChange")

}
