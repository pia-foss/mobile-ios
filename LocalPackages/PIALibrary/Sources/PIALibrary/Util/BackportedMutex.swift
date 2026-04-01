//
//  BackportedMutex.swift
//  PIALibrary
//
//  Created by Mario on 25/03/2026.
//  Copyright © 2026 Private Internet Access, Inc.
//

import Foundation
import Synchronization

import struct os.OSAllocatedUnfairLock

#if os(iOS) || os(tvOS)
    @available(iOS, deprecated: 18, message: "Use Synchronization.Mutex")
    @available(tvOS, deprecated: 18, message: "Use Synchronization.Mutex")
    public typealias Mutex = BackportedMutex
#else
    public typealias Mutex = Synchronization.Mutex
#endif

/// Backport of ``Synchronization.Mutex``.
@available(iOS, deprecated: 18, message: "Use Synchronization.Mutex")
@available(tvOS, deprecated: 18, message: "Use Synchronization.Mutex")
public struct BackportedMutex<Value: ~Copyable>: @unchecked Sendable, ~Copyable {
    #if os(tvOS)
        private let lock = OSAllocatedUnfairLock()
    #else
        @available(iOS, deprecated: 16, message: "Use OSAllocatedUnfairLock")
        private let lock = NSLock()
    #endif
    private let storage: Storage

    public init(_ initialValue: consuming sending Value) {
        self.storage = Storage(initialValue)
    }

    public borrowing func withLock<Result: ~Copyable, E: Error>(
        _ body: (inout sending Value) throws(E) -> sending Result
    ) throws(E) -> sending Result {
        lock.lock()
        defer { lock.unlock() }
        return try body(&storage.value)
    }

    private final class Storage {
        fileprivate var value: Value

        init(_ initialValue: consuming Value) {
            self.value = initialValue
        }
    }
}
