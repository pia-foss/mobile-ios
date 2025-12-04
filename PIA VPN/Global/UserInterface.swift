//
//  UserInterface.swift
//  PIA VPN
//
//  Created by Laura S on 5/10/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import UIKit

struct UserInterface {
    static var userInterfaceIdiom: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }
    
    static var isIpad: Bool {
        userInterfaceIdiom == .pad
    }
    
    static var isPhone: Bool {
        userInterfaceIdiom == .phone
    }
    
    static var isTv: Bool {
        userInterfaceIdiom == .tv
    }
}

