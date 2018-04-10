//
//  LibraryCallback.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/1/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// The standard generic callback type used across the library. Returns a generic object and an optional `Error`. Normally a `nil` object implies a non-`nil` error and viceversa.
public typealias LibraryCallback<T> = (T?, Error?) -> Void

/// A simple callback returning `nil` on success and `Error` on failure.
public typealias SuccessLibraryCallback = (Error?) -> Void
