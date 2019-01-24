//
//  CMacros.m
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 12/17/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

#import <ifaddrs.h>
#import <arpa/inet.h>

#import "CMacros.h"

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
