//
//  UserInterface.swift
//  PIALibrary
//
//  Created by Laura S on 5/10/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import UIKit

public struct UserInterface {
    public static var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
