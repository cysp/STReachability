//
//  STReachability.m
//  STReachability
//
//  Created by Scott Talbot on 11/08/12.
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#if ! (defined(__has_feature) && __has_feature(objc_arc))
# error "STReachability must be compiled with ARC enabled"
#endif


#import "STReachability.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>


@interface STReachability ()
- (id)initWithHost:(NSString *)hostname;
@property (nonatomic,assign) enum STReachabilityStatus status;
@end


extern BOOL STReachabilityStatusIsReachable(enum STReachabilityStatus status) {
    switch (status) {
        case STReachabilityStatusUnknown:
            return NO;
        case STReachabilityStatusUnreachable:
            return NO;
        case STReachabilityStatusReachableViaWifi:
        case STReachabilityStatusReachableViaWWAN:
            return YES;
    }
}

extern BOOL STReachabilityStatusIsUnreachable(enum STReachabilityStatus status) {
    switch (status) {
        case STReachabilityStatusUnknown:
            return NO;
        case STReachabilityStatusUnreachable:
            return YES;
        case STReachabilityStatusReachableViaWifi:
        case STReachabilityStatusReachableViaWWAN:
            return NO;
    }
}


static enum STReachabilityStatus STReachabilityStatusFromFlags(SCNetworkReachabilityFlags flags) {
    if (flags & kSCNetworkReachabilityFlagsReachable) {
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
            return STReachabilityStatusReachableViaWWAN;
        }
        return STReachabilityStatusReachableViaWifi;
    }

    return STReachabilityStatusUnreachable;
}


void STReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    STReachability *reachability = (__bridge STReachability *)(info);
    reachability.status = STReachabilityStatusFromFlags(flags);
}


@implementation STReachability {
    SCNetworkReachabilityRef _reachability;
    CFRunLoopRef _runloop;
    enum STReachabilityStatus _status;
}

+ (STReachability *)reachability {
    return [[self alloc] initWithHost:nil];
}

+ (STReachability *)reachabilityWithHost:(NSString *)hostname {
    return [[self alloc] initWithHost:hostname];
}

- (id)init {
    return [self initWithHost:nil];
}

- (id)initWithHost:(NSString *)hostname {
    NSAssert([NSThread isMainThread], @"not on main thread");
    if ((self = [super init])) {
        _status = STReachabilityStatusUnknown;

        if ([hostname length] == 0) {
            hostname = nil;
        }

        if (hostname) {
            _reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [hostname UTF8String]);
        } else {
            struct sockaddr_in address = {
                .sin_len = sizeof(struct sockaddr_in),
                .sin_family = AF_INET,
                .sin_addr = INADDR_ANY,
            };
            _reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&address);

            SCNetworkReachabilityFlags flags = 0;
            if (SCNetworkReachabilityGetFlags(_reachability, &flags)) {
                _status = STReachabilityStatusFromFlags(flags);
            }
        }
        if (!_reachability) {
            return nil;
        }

        SCNetworkReachabilityContext ctx = {
            .version = 0,
            .info = (__bridge void *)(self),
            .retain = NULL,
            .release = NULL,
        };

        if (!SCNetworkReachabilitySetCallback(_reachability, STReachabilityCallback, &ctx)) {
            return nil;
        }
        CFRetain(_runloop = CFRunLoopGetCurrent());
        if (!SCNetworkReachabilityScheduleWithRunLoop(_reachability, _runloop, kCFRunLoopDefaultMode)) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, _runloop, kCFRunLoopDefaultMode);
    CFRelease(_reachability);
    CFRelease(_runloop);
}


+ (BOOL)automaticallyNotifiesObserversOfStatus { return NO; }
- (void)setStatus:(enum STReachabilityStatus)status {
    if (status != _status) {
        [self willChangeValueForKey:@"status"];
        _status = status;
        [self didChangeValueForKey:@"status"];
    }
}

@end
