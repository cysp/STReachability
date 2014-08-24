//
//  STReachability+Mocking.m
//  STReachability
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STReachability.h"
#import "STReachability+Mocking.h"


static BOOL gSTReachabilityIsMocking = NO;
static NSHashTable *gSTReachabilityMocks = nil;


@interface STMockReachability : NSObject
@property (nonatomic,assign) enum STReachabilityStatus status;
@end


@implementation STReachability (Mocking)

+ (id)allocWithZone:(NSZone *)zone {
	if (gSTReachabilityIsMocking) {
		return (id)[STMockReachability allocWithZone:zone];
	}
	return [super allocWithZone:zone];
}

+ (void)setMocking:(BOOL)mocking {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);
	if (gSTReachabilityIsMocking != mocking) {
		gSTReachabilityIsMocking = mocking;
		if (mocking && !gSTReachabilityMocks) {
			gSTReachabilityMocks = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsObjectPointerPersonality|NSPointerFunctionsWeakMemory capacity:0];
		}
	}
}

+ (void)setMockReachabilityStatus:(enum STReachabilityStatus)status {
	NSAssert([NSThread isMainThread], @"not on main thread", nil);
	for (STMockReachability *mock in gSTReachabilityMocks) {
		[mock setStatus:status];
	}
}

@end


@implementation STMockReachability {
@private
	STReachabilityBlock _block;
}
- (id)init {
	return [self initWithHost:nil block:nil];
}
- (id)initWithHost:(NSString *)host block:(STReachabilityBlock)block {
	if ((self = [super init])) {
		_block = [block copy];

		[gSTReachabilityMocks addObject:self];
	}
	return self;
}
- (void)dealloc {
	[gSTReachabilityMocks removeObject:self];
}
- (BOOL)isKindOfClass:(Class)klass {
	if (klass == [STReachability class]) {
		return YES;
	}
	return [super isKindOfClass:klass];
}
- (BOOL)isMemberOfClass:(Class)klass {
	if (klass == [STReachability class]) {
		return YES;
	}
	return [super isMemberOfClass:klass];
}
+ (BOOL)isSubclassOfClass:(Class)klass {
	if (klass == [STReachability class]) {
		return YES;
	}
	return [super isSubclassOfClass:klass];
}
+ (BOOL)automaticallyNotifiesObserversOfStatus { return NO; }
- (void)setStatus:(enum STReachabilityStatus)status {
	if (status != _status) {
		enum STReachabilityStatus previousStatus = _status;
		[self willChangeValueForKey:@"status"];
		_status = status;
		[self didChangeValueForKey:@"status"];
		if (_block) {
			_block(_status, previousStatus);
		}
	}
}
@end
