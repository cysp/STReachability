//
//  STReachability+Mocking.h
//  STReachability
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STReachability.h"


@interface STReachability (Mocking)

+ (void)setMocking:(BOOL)mocking;
+ (void)setMockReachabilityStatus:(enum STReachabilityStatus)status;

@end
