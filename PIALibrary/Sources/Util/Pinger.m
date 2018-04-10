//
//  Pinger.m
//  PIALibrary
//
//  Created by Davide De Rosa on 3/23/16.
//  Copyright © 2016 London Trust Media. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#import "Pinger.h"

struct timeval PingerTimevalFromMillis(NSInteger millis)
{
    int32_t usecs = (int32_t)millis * 1000;
    const int32_t secs = usecs / USEC_PER_SEC;
    usecs -= secs * USEC_PER_SEC;
    
    struct timeval tv;
    tv.tv_sec = secs;
    tv.tv_usec = usecs;
    return tv;
}

#pragma mark -

@interface TCPPinger ()

@property (nonatomic, copy) NSString *hostname;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, assign) NSInteger timeout;

@end

@implementation TCPPinger

- (instancetype _Nonnull)initWithHostname:(NSString * _Nonnull)hostname port:(uint16_t)port
{
    if ((self = [super init])) {
        self.hostname = hostname;
        self.port = port;
        self.timeout = 0;
    }
    return self;
}

- (NSNumber * _Nullable)sendPing
{
    const int descriptor = socket(PF_INET, SOCK_STREAM, 0);
    if (descriptor == -1) {
//        DDLogError(@"TCPPinger: Unable to create socket (errno: %d)", errno);
        return nil;
    }
    struct sockaddr_in address;
    address.sin_port = htons(self.port);
    address.sin_addr.s_addr = inet_addr(self.hostname.UTF8String);
    address.sin_family = AF_INET;
    
    // XXX: neither of these works for connect timeout
//    if (self.timeout > 0) {
//        const struct timeval tv = PingerTimevalFromMillis(self.timeoutMillis);
//
//        setsockopt(descriptor, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv));
//        setsockopt(descriptor, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
//    }

    BOOL success = NO;
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    const int result = connect(descriptor, (const struct sockaddr *)&address, sizeof(address));
    success = (result == 0);
    const NSInteger responseTime = ([NSDate timeIntervalSinceReferenceDate] - now) * 1000.0;
    close(descriptor);
    
    if (!success) {
//        DDLogError(@"TCPPinger: Unable to connect to %@:%u (errno: %d)", self.hostname, self.port, errno);
        return nil;
    }
    return [NSNumber numberWithInteger:responseTime];
}

@end

#pragma mark -

@interface UDPPinger ()

@property (nonatomic, copy) NSString *hostname;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, assign) NSInteger timeout;

@end

@implementation UDPPinger

- (instancetype _Nonnull)initWithHostname:(NSString * _Nonnull)hostname port:(uint16_t)port
{
    if ((self = [super init])) {
        self.hostname = hostname;
        self.port = port;
        self.timeout = 0;
    }
    return self;
}

- (NSNumber * _Nullable)sendPing
{
    static const char dummyByte[1] = { 'a' };
    
    const int descriptor = socket(PF_INET, SOCK_DGRAM, 0);
    if (descriptor == -1) {
//        DDLogError(@"UDPPinger: Unable to create socket (errno: %d)", errno);
        return nil;
    }
    struct sockaddr_in address;
    address.sin_port = htons(self.port);
    address.sin_addr.s_addr = inet_addr(self.hostname.UTF8String);
    address.sin_family = AF_INET;
    
    if (self.timeout > 0) {
        const struct timeval tv = PingerTimevalFromMillis(self.timeout);
        setsockopt(descriptor, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv));
        setsockopt(descriptor, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
    }

    BOOL success = NO;
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    ssize_t result = sendto(descriptor, dummyByte, sizeof(dummyByte), 0, (const struct sockaddr *)&address, sizeof(address));
    if (result > 0) {
        struct sockaddr fromAddress;
        socklen_t fromAddressSize;
        char received[1];
        result = recvfrom(descriptor, received, 1, 0, (struct sockaddr *)&fromAddress, &fromAddressSize);
//        success = ((result != -1) && (*received == *dummyByte));
        success = (result != -1);
    }
    const NSInteger responseTime = ([NSDate timeIntervalSinceReferenceDate] - now) * 1000;
    close(descriptor);
    
    if (!success) {
//        DDLogError(@"UDPPinger: Unable to ping %@:%u (errno: %d)", self.hostname, self.port, errno);
        return nil;
    }
    return [NSNumber numberWithInteger:responseTime];
}

@end
