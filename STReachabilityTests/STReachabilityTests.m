//
//  STReachabilityTests.m
//  STReachability
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STReachabilityTests.h"

#import "STReachability.h"
#import "STReachability+Mocking.h"


@implementation STReachabilityTests

- (void)setUp {
	[super setUp];

	[STReachability setMocking:YES];
}

- (void)tearDown {
	[STReachability setMocking:NO];

	[super tearDown];
}


- (void)testMocking {
	{
		__block NSUInteger nReachabilityStatusChangesSeen = 0;

		[STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];

		STAssertEquals(nReachabilityStatusChangesSeen, (NSUInteger)0, @"", nil);
	}

	{
		__block NSUInteger nReachabilityStatusChangesSeen = 0;

		[STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];

		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWifi];

		STAssertEquals(nReachabilityStatusChangesSeen, (NSUInteger)1, @"", nil);
	}

	{
		__block NSUInteger nReachabilityStatusChangesSeen = 0;

		[STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];

		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWifi];
		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWWAN];

		STAssertEquals(nReachabilityStatusChangesSeen, (NSUInteger)2, @"", nil);
	}

	{
		__block NSUInteger nReachabilityStatusChangesSeen = 0;

		[STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];
		[STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];

		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWifi];

		STAssertEquals(nReachabilityStatusChangesSeen, (NSUInteger)2, @"", nil);
	}
}

@end
