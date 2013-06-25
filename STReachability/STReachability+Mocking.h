//
//  STReachability+Mocking.h
//  STReachability
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STReachability.h"


@interface STReachability (Mocking)

/**
 * Enable or disable mocking of STReachability objects created after this call
 *
 * @param mocking whether or not to create mocked objects
 */
+ (void)setMocking:(BOOL)mocking;

/**
 * Trigger reachability changes in mocked objects
 *
 * @param status the new reachability status for mocked objects
 */
+ (void)setMockReachabilityStatus:(enum STReachabilityStatus)status;

@end
