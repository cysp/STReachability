//
//  STReachabilityExampleAppDelegate.m
//  STReachability
//
//  Created by Scott Talbot on 9/08/12.
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import "STReachabilityExampleAppDelegate.h"

#import "STReachabilityExampleViewController.h"


@implementation STReachabilityExampleAppDelegate

@synthesize window = _window;
- (void)setWindow:(UIWindow *)window {
    if (_window != window) {
        _window = window;
        [_window makeKeyAndVisible];
    }
}


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];

    STReachabilityExampleViewController *viewController = [[STReachabilityExampleViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [window setRootViewController:navigationController];

    self.window = window;

    return YES;
}

@end
