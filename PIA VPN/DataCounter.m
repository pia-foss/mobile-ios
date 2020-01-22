//
//  DataCounter.m
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2020 Private Internet Access Inc.
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

#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

#import "DataCounter.h"

BOOL DataCounterGetCurrentState(uint32_t *sent, uint32_t *received)
{
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    
    *sent = 0;
    *received = 0;
    
    if (getifaddrs(&addrs) != 0) {
        return NO;
    }
    
    cursor = addrs;
    while (cursor != NULL) {
        if (cursor->ifa_addr->sa_family == AF_LINK) {
            const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
            if (ifa_data != NULL) {
//                DDLogVerbose(@"Data Counter: Interface name %s: sent %tu received %tu", cursor->ifa_name, ifa_data->ifi_obytes, ifa_data->ifi_ibytes);
            }
            
            // name of interfaces:
            // en0 is WiFi
            // pdp_ip0 is WWAN
            NSString *name = [NSString stringWithFormat:@"%s", cursor->ifa_name];
            if ([name hasPrefix:@"en"]) {
                const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                if (ifa_data != NULL) {
//                    WiFiSent += ifa_data->ifi_obytes;
//                    WiFiReceived += ifa_data->ifi_ibytes;
                    *sent += ifa_data->ifi_obytes;
                    *received += ifa_data->ifi_ibytes;
                }
            }
            
            if ([name hasPrefix:@"pdp_ip"]) {
                const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                if (ifa_data != NULL) {
//                    WWANSent += ifa_data->ifi_obytes;
//                    WWANReceived += ifa_data->ifi_ibytes;
                    *sent += ifa_data->ifi_obytes;
                    *received += ifa_data->ifi_ibytes;
                }
            }
        }
        
        cursor = cursor->ifa_next;
    }
    
    freeifaddrs(addrs);
    
    return YES;
}
