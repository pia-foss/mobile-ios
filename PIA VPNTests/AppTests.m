//
//  AppTests.m
//  PIA VPNTests
//
//  Created by Davide De Rosa on 8/4/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSData+Compression.h"
#import "NSData+Crypto.h"
#import "NSString+URL.h"
#import "PIAEphemeralClient.h"

@interface PIAServersResponse ()

+ (SecKeyRef)publicKey;

@end

@interface AppTests : XCTestCase

@end

@implementation AppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCompression
{
    NSString *orig = @"This is a test";
    NSData *deflated = [[orig dataUsingEncoding:NSUTF8StringEncoding] deflated];
    NSLog(@"deflated: %@", deflated);
    NSString *reinflated = [[NSString alloc] initWithData:[deflated inflated] encoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects(orig, reinflated);
}

- (void)testDebugLogSerialization
{
    PIAEphemeralClient *client = [PIAEphemeralClient sharedClient];

    NSString *log = @"2017-08-05 14:31:45.409 DEBUG SessionProxy.handleControlData():733 - Parsed control message (0)\n2017-08-05 14:31:45.409 DEBUG SessionProxy.handleControlData():733 - Parsed control message (0)";
    NSString *debugId;
    NSString *separator;
    NSData *serialized = [client debugDataWithLog:log debugId:&debugId separator:&separator];
    NSLog(@"debugId: %@", debugId);
    NSLog(@"separator (bytes): %@", [separator dataUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"serialized: %@", serialized);

    NSString *printable = [[NSString alloc] initWithData:serialized encoding:NSISOLatin1StringEncoding];
    NSLog(@"printable (%ld chars): %@", printable.length, printable);

    NSString *encoded = [printable urlEncoded];
    NSLog(@"encoded: %@", encoded);
    
    const NSUInteger newlineIndex = [printable rangeOfString:@"\n"].location;
    NSString *origSeparator = [printable substringToIndex:(newlineIndex + 1)];
    XCTAssertEqualObjects(origSeparator, separator);
    
    NSArray *components = [[printable substringFromIndex:(newlineIndex + 1)] componentsSeparatedByString:separator];
    NSLog(@"components: %@", components);
    
    NSData *compressedDebugId = [components[0] dataUsingEncoding:NSISOLatin1StringEncoding];
    NSData *compressedLog = [components[1] dataUsingEncoding:NSISOLatin1StringEncoding];
    NSLog(@"compressedDebugId: %@", compressedDebugId);
    NSLog(@"compressedLog: %@", compressedLog);

    NSString *origDebugIdPrefix = [[NSString alloc] initWithData:[compressedDebugId inflated] encoding:NSISOLatin1StringEncoding];
    NSString *origLog = [[NSString alloc] initWithData:[compressedLog inflated] encoding:NSISOLatin1StringEncoding];

    XCTAssertEqualObjects(origLog, log);
    NSString *debugIdPrefix = [NSString stringWithFormat:@"debug_id\n%@", debugId];
    XCTAssertEqualObjects(origDebugIdPrefix, debugIdPrefix);
}

- (void)testDebugLogSubmission
{
    NSString *log = @"2017-08-05 14:31:45.409 DEBUG SessionProxy.handleControlData():733 - Parsed control message (0)\n2017-08-05 14:31:45.409 DEBUG SessionProxy.handleControlData():733 - Parsed control message (0)";

    XCTestExpectation *exp = [self expectationWithDescription:@"Debug submission"];
    [[PIAEphemeralClient sharedClient] submitDebugLog:log block:^(NSString *debugId, NSString *log) {
        if (debugId) {
            NSLog(@"Debug id: %@", debugId);
            [exp fulfill];
        }
    }];
    [self waitForExpectations:@[exp] timeout:3.0];
}

- (void)testRegionsSignature
{
    XCTestExpectation *exp = [self expectationWithDescription:@"Signature verification"];
    [[PIAEphemeralClient sharedClient] downloadServersVerifying:NO block:^(PIAServersResponse *response, NSError *error) {
        NSLog(@"JSON: %@", response.jsonString);
        NSLog(@"Signature: %@", response.signature);
        
        SecKeyRef key = [PIAServersResponse publicKey];
        NSData *subject = [response.jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *sig = response.signature;
        XCTAssertTrue([subject verifySHA256WithRSASignature:sig publicKey:key]);

        XCTAssertTrue([response verifySignature]);
        
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:5.0];
}

@end
