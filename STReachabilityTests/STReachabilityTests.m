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
	[STReachability reachabilityWithBlock:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:.5];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	STAssertEquals(reachabilityStatusesSeenCount, (NSUInteger)1, @"", nil);
	if (reachabilityStatusesSeenCount > 0) {
		STAssertTrue(STReachabilityStatusIsReachable([reachabilityStatusesSeen[0] unsignedIntegerValue]), @"", nil);
	}
}

- (void)testReachabilityLiteralAddressIPv4 {
	NSMutableArray * const reachabilityStatusesSeen = [[NSMutableArray alloc] initWithCapacity:1];
	[STReachability reachabilityWithHost:@"8.8.8.8" block:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:.5];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	STAssertEquals(reachabilityStatusesSeenCount, (NSUInteger)1, @"", nil);
	if (reachabilityStatusesSeenCount > 0) {
		STAssertTrue(STReachabilityStatusIsReachable([reachabilityStatusesSeen[0] unsignedIntegerValue]), @"", nil);
	}
}

- (void)testReachabilityNameResolutionFailure {
	NSMutableArray * const reachabilityStatusesSeen = [[NSMutableArray alloc] initWithCapacity:1];
	[STReachability reachabilityWithHost:@"nonexistent.example.org" block:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:.5];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	STAssertEquals(reachabilityStatusesSeenCount, (NSUInteger)1, @"", nil);
	if (reachabilityStatusesSeenCount > 0) {
		STAssertTrue(STReachabilityStatusIsUnreachable([reachabilityStatusesSeen[0] unsignedIntegerValue]), @"", nil);
	}
}

- (void)testReachabilityNameResolutionSuccess {
	NSMutableArray * const reachabilityStatusesSeen = [[NSMutableArray alloc] initWithCapacity:1];
	[STReachability reachabilityWithHost:@"example.org" block:^(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus) {
		[reachabilityStatusesSeen addObject:@(status)];
	}];

	NSDate * const resolutionTimeout = [NSDate dateWithTimeIntervalSinceNow:.5];
	[[NSRunLoop mainRunLoop] runUntilDate:resolutionTimeout];

	NSUInteger const reachabilityStatusesSeenCount = [reachabilityStatusesSeen count];
	STAssertEquals(reachabilityStatusesSeenCount, (NSUInteger)1, @"", nil);
	if (reachabilityStatusesSeenCount > 0) {
		STAssertTrue(STReachabilityStatusIsReachable([reachabilityStatusesSeen[0] unsignedIntegerValue]), @"", nil);
	}
}

@end
