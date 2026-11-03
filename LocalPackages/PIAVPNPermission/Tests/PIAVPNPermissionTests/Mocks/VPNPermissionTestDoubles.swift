//
//  VPNPermissionTestDoubles.swift
//  PIAVPNPermissionTests
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

@testable import PIAVPNPermission

@MainActor
final class VPNPermissionDependencySpy {
    var requestResult: Result<Void, any Error> = .success(())
    var canSendMail = false
    private(set) var requestCallCount = 0
    private(set) var emittedOutputs: [VPNPermission.Output] = []

    func makeDependencies() -> VPNPermission.Dependencies {
        .init(
            requestPermission: { [self] in
                requestCallCount += 1
                return requestResult
            },
            canSendMail: { [self] in canSendMail },
            emit: { [self] output in emittedOutputs.append(output) }
        )
    }
}

struct VPNPermissionTestError: Error {}
