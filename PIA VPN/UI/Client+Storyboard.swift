//
//  Client+Storyboard.swift
//  PIA VPN
//
//  Created by Said Rehouni on 26/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import UIKit

extension Client {
    /**
     Returns the Signup Storyboard owned by the library to be used by the clients
     */
    public static func signupStoryboard() -> UIStoryboard {
        UIStoryboard(name: "Signup", bundle: Bundle.main)
    }
}
