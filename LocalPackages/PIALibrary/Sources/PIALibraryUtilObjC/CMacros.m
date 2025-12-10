//
//  CMacros.m
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 12/17/17.
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

#import <ifaddrs.h>
#import <arpa/inet.h>

#import "CMacros.h"

// FIXME: This method always returns a string no matter if the vpn is connected or not
NSString *VPNIPAddressFromInterfaces()
{
    struct ifaddrs *ifAddrs;
    
    if (getifaddrs(&ifAddrs)) {
        return nil;
    }
    
    NSString *vpnIpAddress = nil;
    struct sockaddr_in *s4;
    char buf[64];
    struct ifaddrs *ifAddr = ifAddrs;
    
    while (ifAddr != NULL) {
        if (ifAddr->ifa_addr->sa_family == AF_INET) {
            NSString *ifName = [NSString stringWithUTF8String:ifAddr->ifa_name];
            
            s4 = (struct sockaddr_in *)ifAddr->ifa_addr;
            
            if (inet_ntop(ifAddr->ifa_addr->sa_family, (void *) &s4->sin_addr, buf, sizeof(buf)) != NULL) {
                NSString *ifIpAddress = [NSString stringWithUTF8String:buf];
                
//                NSLog(@"Interfaces: %@ = %@", ifName, ifIpAddress);
                
                if ([ifName hasPrefix:@"utun"] || [ifName hasPrefix:@"ppp"] || [ifName hasPrefix:@"ipsec0"]) {
                    vpnIpAddress = ifIpAddress;
                }
            }
        }
        ifAddr = ifAddr->ifa_next;
    }
    
    freeifaddrs(ifAddrs);
    
    return vpnIpAddress;
}
