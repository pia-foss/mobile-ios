//
//  String+AddDetailSymbol.swift
//  PIA VPN
//
//  Created by Waleed Mahmood on 15.02.22.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    func appendDetailSymbol() -> String {
        let symbol = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? "⟨ " : " ⟩"
        return "\(self)\(symbol)"
    }
}
