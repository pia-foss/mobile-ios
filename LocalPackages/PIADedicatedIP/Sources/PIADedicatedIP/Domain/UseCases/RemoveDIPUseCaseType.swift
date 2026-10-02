//
//  RemoveDIPUseCaseType.swift
//  PIADedicatedIP
//
//  Created by Said Rehouni on 19/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

public protocol RemoveDIPUseCaseType: Sendable {
    func callAsFunction() async -> Result<Void, RemoveDedicatedIPError>
}
