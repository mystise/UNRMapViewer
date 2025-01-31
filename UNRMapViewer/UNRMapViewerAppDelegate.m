//
//  UNRMapViewerAppDelegate.m
//  UNRMapViewer
//
//  Created by Adalynn Dudney on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UNRMapViewerAppDelegate.h"
#import "EAGLView.h"
#import "UNRMapViewerViewController.h"
#import "UNRMapSelectionViewController.h"

@implementation UNRMapViewerAppDelegate

@synthesize window=_window;
@synthesize viewController=_viewController;
@synthesize listController=_listController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
	// Override point for customization after application launch.
	//self.window.rootViewController = self.viewController;
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
	//[self.viewController stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 ifyour application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. if the application was previously in the background, optionally refresh the user interface.
	 */
	//[self.viewController startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application{
	/*
	 Called when the application is about to terminate.
	 Save data ifappropriate.
	 See also applicationDidEnterBackground:.
	 */
	//[self.viewController stopAnimation];
}

- (void)dealloc{
	[_window release];
	[_viewController release];
	[_listController release];
	[super dealloc];
}

@end
