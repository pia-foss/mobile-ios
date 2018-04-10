//
//  Pinger.h
//  PIALibrary
//
//  Created by Davide De Rosa on 3/23/16.
//  Copyright © 2016 London Trust Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Pinger <NSObject>

- (NSNumber * _Nullable)sendPing; // blocking
- (void)setTimeout:(NSInteger)timeout;

@end

@interface TCPPinger : NSObject <Pinger>

- (instancetype _Nonnull)initWithHostname:(NSString * _Nonnull)hostname port:(uint16_t)port;

@end

@interface UDPPinger : NSObject <Pinger>

- (instancetype _Nonnull)initWithHostname:(NSString * _Nonnull)hostname port:(uint16_t)port;

@end
