//
//  BBAppDelegate.m
//  CircleView
//
//  Created by Bharath Booshan on 6/8/12.
//  Copyright (c) 2012 Bharath Booshan Inc All rights reserved.
//

#import "BBAppDelegate.h"

#import "BBViewController.h"

@implementation BBAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	self.viewController = [[BBViewController alloc] initWithNibName:@"BBViewController" bundle:nil];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = self.viewController;
	
	[self.window makeKeyAndVisible];
	
	return YES;
	
}

@end
