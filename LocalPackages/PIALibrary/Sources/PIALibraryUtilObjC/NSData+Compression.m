//
//  NSData+Compression.m
//  PIALibrary
//
//  Created by Davide De Rosa on 8/4/17.
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

#import <zlib.h>

#import "NSData+Compression.h"

static const size_t NSDataCompressionBlockSize = 16384;

@implementation NSData (Compression)

- (NSData *)deflated
{
    if (self.length == 0) {
        return self;
    }
    
    z_stream strm;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    
    if (deflateInit2(&strm, Z_BEST_COMPRESSION, Z_DEFLATED, MAX_WBITS, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY) != Z_OK) {
        return nil;
    }
    
    NSMutableData *compressed = [[NSMutableData alloc] initWithLength:NSDataCompressionBlockSize];
    strm.next_in = (Bytef *)self.bytes;
    strm.avail_in = (uInt)self.length;

    do {
        if (strm.total_out >= compressed.length) {
            [compressed increaseLengthBy:NSDataCompressionBlockSize];
        }
        strm.next_out = compressed.mutableBytes + strm.total_out;
        strm.avail_out = (uInt)(compressed.length - strm.total_out);
        
        deflate(&strm, Z_FINISH);
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    compressed.length = strm.total_out;
    return compressed;
}

- (NSData *)inflated
{
    if (self.length == 0) {
        return self;
    }
    
    unsigned fullLength = (unsigned)self.length;
    unsigned halfLength = (unsigned)self.length / 2;
    
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.total_out = 0;

    if (inflateInit2(&strm, MAX_WBITS) != Z_OK) {
        return nil;
    }
    
    NSMutableData *decompressed = [[NSMutableData alloc] initWithLength:fullLength + halfLength];
    strm.next_in = (Bytef *)self.bytes;
    strm.avail_in = (uInt)self.length;

    while (!done) {
        if (strm.total_out >= decompressed.length) {
            [decompressed increaseLengthBy:halfLength];
        }
        strm.next_out = decompressed.mutableBytes + strm.total_out;
        strm.avail_out = (uInt)(decompressed.length - strm.total_out);
        
        status = inflate(&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        }
        else if (status != Z_OK) {
            break;
        }
    }
    if (inflateEnd(&strm) != Z_OK) {
        return nil;
    }
    if (!done) {
        return nil;
    }

    decompressed.length = strm.total_out;
    return decompressed;
}

@end
