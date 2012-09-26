//
//  STReachability.h
//  STReachability
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012 Scott Talbot.
//

#import <Foundation/Foundation.h>


NS_ENUM(NSInteger, STReachabilityStatus) {
    STReachabilityStatusUnknown = -1,
    STReachabilityStatusUnreachable = 0,
    STReachabilityStatusReachableViaWifi = 1,
    STReachabilityStatusReachableViaWWAN = 2,
};

extern BOOL STReachabilityStatusIsReachable(enum STReachabilityStatus);
extern BOOL STReachabilityStatusIsUnreachable(enum STReachabilityStatus);


@interface STReachability : NSObject

+ (STReachability *)reachability;
+ (STReachability *)reachabilityWithHost:(NSString *)hostname;

@property (nonatomic,assign,readonly) enum STReachabilityStatus status;

@end
