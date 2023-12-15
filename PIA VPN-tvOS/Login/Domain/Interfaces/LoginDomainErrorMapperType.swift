//
//  LoginDomainErrorMapperType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 4/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol LoginDomainErrorMapperType {
    func map(error: Error?) -> LoginError
}
