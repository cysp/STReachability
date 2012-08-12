//
//  STReachability.h
//  STReachability
//
//  Created by Scott Talbot on 11/08/12.
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
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
