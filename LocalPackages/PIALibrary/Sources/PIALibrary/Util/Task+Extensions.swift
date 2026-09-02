//
//  Task+Extensions.swift
//  PIALibrary
//
//  Created by Mario on 18/08/2026.
//  Copyright © 2020 Private Internet Access, Inc.
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

public extension Task where Failure == Never, Success == Void {
    /// Run an async operation in a synchronous context, and wait for it to finish.
    ///
    /// Blocks the thread until the operation is finished. The caller is responsible for managing multithreading.
    static func blockingThreadUnsafe(
        name: String? = nil,
        priority: TaskPriority? = nil,
        operation: sending @escaping @isolated(any) () async -> Void
    ) {
        let semaphore = DispatchSemaphore(value: 0)
        Task(name: name, priority: priority) {
            await operation()
            semaphore.signal()
        }
        semaphore.wait()
    }
}
