//
//  STReachability.m
//  STReachability
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012 Scott Talbot.
//

#if ! (defined(__has_feature) && __has_feature(objc_arc))
# error "STReachability must be compiled with ARC enabled"
#endif


#import "STReachability.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <arpa/inet.h>


@interface STReachability ()
- (id)initWithHost:(NSString *)hostname block:(STReachabilityBlock)block;
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


static NSString *NSStringCreateFromReachabilityFlags(SCNetworkReachabilityFlags flags) {
    char cstr[11] = "--,-------";

    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
        cstr[0] = 'W';
    }
    if (flags & kSCNetworkReachabilityFlagsReachable) {
        cstr[1] = 'R';
    }

    if (flags & kSCNetworkReachabilityFlagsConnectionRequired) {
        cstr[3] = 'c';
    }
    if (flags & kSCNetworkReachabilityFlagsTransientConnection) {
        cstr[4] = 't';
    }
    if (flags & kSCNetworkReachabilityFlagsInterventionRequired) {
        cstr[5] = 'i';
    }
    if (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) {
        cstr[6] = 'C';
    }
    if (flags & kSCNetworkReachabilityFlagsConnectionOnDemand) {
        cstr[7] = 'D';
    }
    if (flags & kSCNetworkReachabilityFlagsIsLocalAddress) {
        cstr[8] = 'l';
    }
    if (flags & kSCNetworkReachabilityFlagsIsDirect) {
        cstr[9] = 'd';
    }

    return [[NSString alloc] initWithBytes:cstr length:sizeof(cstr) encoding:NSASCIIStringEncoding];
}


static enum STReachabilityStatus STReachabilityStatusFromFlags(SCNetworkReachabilityFlags flags) {
    if (flags & kSCNetworkReachabilityFlagsReachable) {
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
            return STReachabilityStatusReachableViaWWAN;
        }

        // the following voodoo comes from DDG (via ASI)
        SCNetworkReachabilityFlags interestingFlags = flags & (kSCNetworkReachabilityFlagsConnectionRequired|kSCNetworkReachabilityFlagsTransientConnection|kSCNetworkReachabilityFlagsInterventionRequired|kSCNetworkReachabilityFlagsConnectionOnTraffic|kSCNetworkReachabilityFlagsConnectionOnDemand);

        if (interestingFlags == (kSCNetworkReachabilityFlagsConnectionRequired|kSCNetworkReachabilityFlagsTransientConnection)) {
            return STReachabilityStatusUnreachable;
        }

        if (interestingFlags & (kSCNetworkFlagsConnectionRequired|kSCNetworkFlagsTransientConnection)) {
            return STReachabilityStatusReachableViaWifi;
        }
        if (interestingFlags == 0) {
            return STReachabilityStatusReachableViaWifi;
        }

        NSCAssert(0, @"unreachable (pun intended)", nil);
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
    STReachabilityBlock _block;
}

+ (STReachability *)reachability {
    return [[self alloc] initWithHost:nil block:nil];
}

+ (STReachability *)reachabilityWithBlock:(STReachabilityBlock)block {
    return [[self alloc] initWithHost:nil block:block];
}

+ (STReachability *)reachabilityWithHost:(NSString *)hostname {
    return [[self alloc] initWithHost:hostname block:nil];
}

+ (STReachability *)reachabilityWithHost:(NSString *)hostname block:(STReachabilityBlock)block {
    return [[self alloc] initWithHost:hostname block:block];
}

- (id)init {
    return [self initWithHost:nil block:nil];
}

- (id)initWithHost:(NSString *)host block:(STReachabilityBlock)block {
    NSAssert([NSThread isMainThread], @"not on main thread", nil);
    if ((self = [super init])) {
        _status = STReachabilityStatusUnknown;

        if ([host length] == 0) {
            host = nil;
        }

        if (host) {
            const char *host_cstr = [host UTF8String];

            struct sockaddr_in address_v4 = {
                .sin_len = sizeof(struct sockaddr_in),
                .sin_family = AF_INET,
            };
            struct sockaddr_in6 address_v6 = {
                .sin6_len = sizeof(struct sockaddr_in6),
                .sin6_family = AF_INET6,
            };

            struct sockaddr *address = NULL;
            if (inet_pton(AF_INET, host_cstr, &address_v4.sin_addr) == 1) {
                address = (struct sockaddr *)&address_v4;
            } else if (inet_pton(AF_INET6, host_cstr, &address_v6.sin6_addr) == 1) {
                address = (struct sockaddr *)&address_v6;
            }

            if (address) {
                _reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, address);

                SCNetworkReachabilityFlags flags = 0;
                if (SCNetworkReachabilityGetFlags(_reachability, &flags)) {
                    _status = STReachabilityStatusFromFlags(flags);
                }
            } else {
                _reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, host_cstr);
            }
        } else {
            struct sockaddr_in address = {
                .sin_len = sizeof(struct sockaddr_in),
                .sin_family = AF_INET,
                .sin_addr = { .s_addr = INADDR_ANY },
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

        _block = [block copy];

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
    if (_reachability && _runloop) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, _runloop, kCFRunLoopDefaultMode);
    }
    if (_reachability) {
        CFRelease(_reachability);
    }
    if (_runloop) {
        CFRelease(_runloop);
    }
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
