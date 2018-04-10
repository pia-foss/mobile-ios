//
//  NSString+URL.m
//  PIALibrary
//
//  Created by Davide De Rosa on 12/15/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString (URL)

- (NSString *)urlEncoded
{
    // XXX: non-deprecated methods don't seem to allow the ISOLatin1 option and result in bad zlib headers
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (CFStringRef)self,
                                                                        NULL,
                                                                        (CFStringRef)@"!'();:@&=+$,/?%#[]",
                                                                        kCFStringEncodingISOLatin1);
}

@end
