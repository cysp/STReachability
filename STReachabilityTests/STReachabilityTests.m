//
//  STReachabilityTests.m
//  STReachability
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

@import XCTest;

#import "STReachability.h"
#import "STReachability+Mocking.h"


@interface STReachabilityTests : XCTestCase @end

@implementation STReachabilityTests

- (void)setUp {
	[super setUp];

	if ([self.name hasSuffix:@"Mocked]"]) {
		[STReachability setMocking:YES];
	}
}

- (void)tearDown {
	[STReachability setMocking:NO];

	[super tearDown];
}


- (void)testMocked {
	{
		__block NSUInteger nReachabilityStatusChangesSeen = 0;

		STReachability * const reachability = [STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];
		XCTAssertNotNil(reachability, @"");
		if (!reachability) {
			return;
		}

		XCTAssertEqual(nReachabilityStatusChangesSeen, (NSUInteger)0);

		(void)reachability;
	}

	{
		__block NSUInteger nReachabilityStatusChangesSeen = 0;

		STReachability * const reachability = [STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];
		XCTAssertNotNil(reachability, @"");
		if (!reachability) {
			return;
		}

		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWifi];

		XCTAssertEqual(nReachabilityStatusChangesSeen, (NSUInteger)1);

		(void)reachability;
	}

	{
		__block NSUInteger nReachabilityStatusChangesSeen = 0;

		STReachability * const reachability = [STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];
		XCTAssertNotNil(reachability, @"");
		if (!reachability) {
			return;
		}

		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWifi];
		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWWAN];

		XCTAssertEqual(nReachabilityStatusChangesSeen, (NSUInteger)2);

		(void)reachability;
	}

	{
		__block NSUInteger nReachabilityStatusChangesSeen = 0;

		STReachability * const reachability1 = [STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];
		XCTAssertNotNil(reachability1, @"");
		if (!reachability1) {
			return;
		}

		STReachability * const reachability2 = [STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];
		XCTAssertNotNil(reachability2, @"");
		if (!reachability2) {
			return;
		}

		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWifi];

		XCTAssertEqual(nReachabilityStatusChangesSeen, (NSUInteger)2);

		(void)reachability1;
		(void)reachability2;
	}
}

- (void)testRetainCycle {
	__weak STReachability *reachability = nil;
	@autoreleasepool {
		reachability = [STReachability reachability];
	}
	XCTAssertNil(reachability);
}

- (void)testRetainCycleMocked {
	__weak STReachability *reachability = nil;
	@autoreleasepool {
		reachability = [STReachability reachability];
	}
	XCTAssertNil(reachability);
}

- (void)testReachabilityInternet {
	NSMutableArray * const reachabilityStatusesSeen = [[NSMutableArray alloc] initWithCapacity:1];
	STReachability * const reachability = [STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];
	XCTAssertNotNil(reachability, @"");
	if (!reachability) {
		return;
	}

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:.5];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	XCTAssertEqual(reachabilityStatusesSeenCount, (NSUInteger)1);
	if (reachabilityStatusesSeenCount > 0) {
		XCTAssertTrue(STReachabilityStatusIsReachable([reachabilityStatusesSeen[0] unsignedIntegerValue]));
	}

	(void)reachability;
}

- (void)testReachabilityLiteralAddressIPv4 {
	NSMutableArray * const reachabilityStatusesSeen = [[NSMutableArray alloc] initWithCapacity:1];
	STReachability * const reachability = [STReachability reachabilityWithHost:@"8.8.8.8" block:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];
	XCTAssertNotNil(reachability, @"");
	if (!reachability) {
		return;
	}

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:.5];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	XCTAssertEqual(reachabilityStatusesSeenCount, (NSUInteger)1);
	if (reachabilityStatusesSeenCount > 0) {
		XCTAssertTrue(STReachabilityStatusIsReachable([reachabilityStatusesSeen[0] unsignedIntegerValue]));
	}

	(void)reachability;
}

- (void)testReachabilityNameResolutionFailure {
	NSMutableArray * const reachabilityStatusesSeen = [[NSMutableArray alloc] initWithCapacity:1];
	STReachability * const reachability = [STReachability reachabilityWithHost:@"nonexistent.example.org" block:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];
	XCTAssertNotNil(reachability, @"");
	if (!reachability) {
		return;
	}

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:1];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	XCTAssertEqual(reachabilityStatusesSeenCount, (NSUInteger)1);
	if (reachabilityStatusesSeenCount > 0) {
		XCTAssertTrue(STReachabilityStatusIsUnreachable([reachabilityStatusesSeen[0] unsignedIntegerValue]));
	}

	(void)reachability;
}

- (void)testReachabilityNameResolutionSuccess {
	NSMutableArray * const reachabilityStatusesSeen = [[NSMutableArray alloc] initWithCapacity:1];
	STReachability * const reachability = [STReachability reachabilityWithHost:@"example.org" block:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];
	XCTAssertNotNil(reachability, @"");
	if (!reachability) {
		return;
	}

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:.5];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	XCTAssertEqual(reachabilityStatusesSeenCount, (NSUInteger)1);
	if (reachabilityStatusesSeenCount > 0) {
		XCTAssertTrue(STReachabilityStatusIsReachable([reachabilityStatusesSeen[0] unsignedIntegerValue]));
	}

	(void)reachability;
}

@end
