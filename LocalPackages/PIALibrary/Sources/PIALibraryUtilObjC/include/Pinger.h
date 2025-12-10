//
//  Pinger.h
//  PIALibrary
//
//  Created by Davide De Rosa on 3/23/16.
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
