//
//  DataCounter.m
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
