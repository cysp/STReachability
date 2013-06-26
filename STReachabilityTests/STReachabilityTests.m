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

- (void)setUpTestWithSelector:(SEL)testMethod {
	[super setUpTestWithSelector:testMethod];

	NSString * const testMethodString = NSStringFromSelector(testMethod);
	if ([testMethodString hasSuffix:@"Mocked"]) {
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
		STAssertNotNil(reachability, @"");
		if (!reachability) {
			return;
		}

		STAssertEquals(nReachabilityStatusChangesSeen, (NSUInteger)0, @"", nil);

		(void)reachability;
	}

	{
		__block NSUInteger nReachabilityStatusChangesSeen = 0;

		STReachability * const reachability = [STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];
		STAssertNotNil(reachability, @"");
		if (!reachability) {
			return;
		}

		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWifi];

		STAssertEquals(nReachabilityStatusChangesSeen, (NSUInteger)1, @"", nil);

		(void)reachability;
	}

	{
		__block NSUInteger nReachabilityStatusChangesSeen = 0;

		STReachability * const reachability = [STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];
		STAssertNotNil(reachability, @"");
		if (!reachability) {
			return;
		}

		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWifi];
		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWWAN];

		STAssertEquals(nReachabilityStatusChangesSeen, (NSUInteger)2, @"", nil);

		(void)reachability;
	}

	{
		__block NSUInteger nReachabilityStatusChangesSeen = 0;

		STReachability * const reachability1 = [STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];
		STAssertNotNil(reachability1, @"");
		if (!reachability1) {
			return;
		}

		STReachability * const reachability2 = [STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
			++nReachabilityStatusChangesSeen;
		}];
		STAssertNotNil(reachability2, @"");
		if (!reachability2) {
			return;
		}

		[STReachability setMockReachabilityStatus:STReachabilityStatusReachableViaWifi];

		STAssertEquals(nReachabilityStatusChangesSeen, (NSUInteger)2, @"", nil);

		(void)reachability1;
		(void)reachability2;
	}
}

- (void)testRetainCycle {
	__weak STReachability *reachability = nil;
	@autoreleasepool {
		reachability = [STReachability reachability];
	}
	STAssertNil(reachability, @"", nil);
}

- (void)testRetainCycleMocked {
	__weak STReachability *reachability = nil;
	@autoreleasepool {
		reachability = [STReachability reachability];
	}
	STAssertNil(reachability, @"", nil);
}

- (void)testReachabilityInternet {
	NSMutableArray * const reachabilityStatusesSeen = [[NSMutableArray alloc] initWithCapacity:1];
	STReachability * const reachability = [STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];
	STAssertNotNil(reachability, @"");
	if (!reachability) {
		return;
	}

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:.5];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	STAssertEquals(reachabilityStatusesSeenCount, (NSUInteger)1, @"", nil);
	if (reachabilityStatusesSeenCount > 0) {
		STAssertTrue(STReachabilityStatusIsReachable([reachabilityStatusesSeen[0] unsignedIntegerValue]), @"", nil);
	}

	(void)reachability;
}

- (void)testReachabilityLiteralAddressIPv4 {
	NSMutableArray * const reachabilityStatusesSeen = [[NSMutableArray alloc] initWithCapacity:1];
	STReachability * const reachability = [STReachability reachabilityWithHost:@"8.8.8.8" block:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];
	STAssertNotNil(reachability, @"");
	if (!reachability) {
		return;
	}

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:.5];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	STAssertEquals(reachabilityStatusesSeenCount, (NSUInteger)1, @"", nil);
	if (reachabilityStatusesSeenCount > 0) {
		STAssertTrue(STReachabilityStatusIsReachable([reachabilityStatusesSeen[0] unsignedIntegerValue]), @"", nil);
	}

	(void)reachability;
}

- (void)testReachabilityNameResolutionFailure {
	NSMutableArray * const reachabilityStatusesSeen = [[NSMutableArray alloc] initWithCapacity:1];
	STReachability * const reachability = [STReachability reachabilityWithHost:@"nonexistent.example.org" block:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];
	STAssertNotNil(reachability, @"");
	if (!reachability) {
		return;
	}

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:1];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	STAssertEquals(reachabilityStatusesSeenCount, (NSUInteger)1, @"", nil);
	if (reachabilityStatusesSeenCount > 0) {
		STAssertTrue(STReachabilityStatusIsUnreachable([reachabilityStatusesSeen[0] unsignedIntegerValue]), @"", nil);
	}

	(void)reachability;
}

- (void)testReachabilityNameResolutionSuccess {
	NSMutableArray * const reachabilityStatusesSeen = [[NSMutableArray alloc] initWithCapacity:1];
	STReachability * const reachability = [STReachability reachabilityWithHost:@"example.org" block:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];
	STAssertNotNil(reachability, @"");
	if (!reachability) {
		return;
	}

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:.5];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	STAssertEquals(reachabilityStatusesSeenCount, (NSUInteger)1, @"", nil);
	if (reachabilityStatusesSeenCount > 0) {
		STAssertTrue(STReachabilityStatusIsReachable([reachabilityStatusesSeen[0] unsignedIntegerValue]), @"", nil);
	}

	(void)reachability;
}

@end
