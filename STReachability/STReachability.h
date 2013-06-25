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

/**
 * Determine whether a status code implies reachability
 */
extern BOOL STReachabilityStatusIsReachable(enum STReachabilityStatus);
/**
 * Determine whether a status code implies unreachability
 */
extern BOOL STReachabilityStatusIsUnreachable(enum STReachabilityStatus);


typedef void(^STReachabilityBlock)(enum STReachabilityStatus status, enum STReachabilityStatus previousStatus);


/**
 * Provides an Objective-C interface onto SCNetworkReachability
 */
@interface STReachability : NSObject

/** @name Creation Methods */

/**
 * Create a STReachability object for "The Internet"
 *
 * @see +reachabilityWithBlock:
 */
+ (STReachability *)reachability;
/**
 * Create a STReachability object for "The Internet"
 *
 * @param block a handler block to execute when connectivity changes
 */
+ (STReachability *)reachabilityWithBlock:(STReachabilityBlock)block;

/**
 * Create a STReachability object for a specific host
 *
 * @param hostname the host to use for reachability (hostname or literal address)
 * @see +reachabilityWithHost:block:
 */
+ (STReachability *)reachabilityWithHost:(NSString *)hostname;
/**
 * Create a STReachability object for a specific host
 *
 * @param hostname the host to use for reachability (hostname or literal address)
 * @param block a handler block to execute when connectivity changes
 */
+ (STReachability *)reachabilityWithHost:(NSString *)hostname block:(STReachabilityBlock)block;

/** @name Status Methods */

/**
 * The latest reachability status seen
 */
@property (nonatomic,assign,readonly) enum STReachabilityStatus status;

@end
