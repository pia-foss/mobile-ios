//
//  Daemon.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/16/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

protocol Daemon: class {
    var hasEnabledUpdates: Bool { get }
    
    func start()
    
    func enableUpdates()
}

extension Daemon {
    func enableUpdates() {
    }
}
