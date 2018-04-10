//
//  NSData+Compression.h
//  PIALibrary
//
//  Created by Davide De Rosa on 8/4/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Compression)

- (NSData *)deflated;
- (NSData *)inflated;

@end
