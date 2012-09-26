//
//  STReachabilityDemoApplicationDelegate.m
//  STReachability
//
//  Copyright (c) 2012 Scott Talbot. All rights reserved.
//

#import "STReachabilityDemoApplicationDelegate.h"

#import "STReachabilityDemoViewController.h"


@implementation STReachabilityDemoApplicationDelegate

@synthesize window = _window;
- (void)setWindow:(UIWindow *)window {
    if (_window != window) {
        _window = window;
        [_window makeKeyAndVisible];
    }
}


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    STReachabilityDemoViewController *viewController = [[STReachabilityDemoViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [window setRootViewController:navigationController];

    self.window = window;

    return YES;
}

@end
