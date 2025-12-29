//
//  Data+Compression.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 29/12/25.
//  Copyright © 2025 Private Internet Access, Inc.
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
import zlib

private let compressionBlockSize = 16384

extension Data {
    /// Compresses the data using zlib deflate algorithm.
    /// - Returns: The compressed data, or nil if compression fails.
    func deflated() -> Data? {
        guard !isEmpty else {
            return self
        }

        var stream = z_stream()
        stream.zalloc = nil
        stream.zfree = nil
        stream.opaque = nil
        stream.total_out = 0

        guard deflateInit2_(&stream, Z_BEST_COMPRESSION, Z_DEFLATED, MAX_WBITS, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size)) == Z_OK else {
            return nil
        }

        defer {
            deflateEnd(&stream)
        }

        var compressed = Data(count: compressionBlockSize)
        var compressedSize = compressed.count

        let result: Data? = withUnsafeBytes { (inputBytes: UnsafeRawBufferPointer) -> Data? in
            guard let inputBaseAddress = inputBytes.bindMemory(to: UInt8.self).baseAddress else {
                return nil
            }
            stream.next_in = UnsafeMutablePointer<UInt8>(mutating: inputBaseAddress)
            stream.avail_in = uInt(count)

            repeat {
                if Int(stream.total_out) >= compressedSize {
                    compressedSize += compressionBlockSize
                    compressed.count = compressedSize
                }

                let status = compressed.withUnsafeMutableBytes { (outputBytes: UnsafeMutableRawBufferPointer) -> Int32 in
                    guard let outputBaseAddress = outputBytes.bindMemory(to: UInt8.self).baseAddress else {
                        return Z_STREAM_ERROR
                    }
                    stream.next_out = outputBaseAddress.advanced(by: Int(stream.total_out))
                    stream.avail_out = uInt(compressedSize - Int(stream.total_out))
                    return deflate(&stream, Z_FINISH)
                }

                if status < 0 {
                    return nil
                }
            } while stream.avail_out == 0

            compressed.count = Int(stream.total_out)
            return compressed
        }

        return result
    }

    /// Decompresses the data using zlib inflate algorithm.
    /// - Returns: The decompressed data, or nil if decompression fails.
    func inflated() -> Data? {
        guard !isEmpty else {
            return self
        }

        let fullLength = count
        let halfLength = count / 2

        var stream = z_stream()
        stream.zalloc = nil
        stream.zfree = nil
        stream.total_out = 0

        guard inflateInit2_(&stream, MAX_WBITS, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size)) == Z_OK else {
            return nil
        }

        defer {
            inflateEnd(&stream)
        }

        var decompressed = Data(count: fullLength + halfLength)
        var decompressedSize = decompressed.count
        var done = false

        let result: Data? = withUnsafeBytes { (inputBytes: UnsafeRawBufferPointer) -> Data? in
            guard let inputBaseAddress = inputBytes.bindMemory(to: UInt8.self).baseAddress else {
                return nil
            }
            stream.next_in = UnsafeMutablePointer<UInt8>(mutating: inputBaseAddress)
            stream.avail_in = uInt(count)

            while !done {
                if Int(stream.total_out) >= decompressedSize {
                    decompressedSize += halfLength
                    decompressed.count = decompressedSize
                }

                let status = decompressed.withUnsafeMutableBytes { (outputBytes: UnsafeMutableRawBufferPointer) -> Int32 in
                    guard let outputBaseAddress = outputBytes.bindMemory(to: UInt8.self).baseAddress else {
                        return Z_STREAM_ERROR
                    }
                    stream.next_out = outputBaseAddress.advanced(by: Int(stream.total_out))
                    stream.avail_out = uInt(decompressedSize - Int(stream.total_out))
                    return inflate(&stream, Z_SYNC_FLUSH)
                }

                if status == Z_STREAM_END {
                    done = true
                } else if status != Z_OK {
                    return nil
                }
            }

            guard inflateEnd(&stream) == Z_OK else {
                return nil
            }

            guard done else {
                return nil
            }

            decompressed.count = Int(stream.total_out)
            return decompressed
        }

        return result
    }
}
