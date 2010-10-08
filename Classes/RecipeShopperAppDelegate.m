//
//  RecipeShopperAppDelegate.m
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright Assentec 2010. All rights reserved.
//

#import "RecipeShopperAppDelegate.h"
#import "DataManager.h"

@implementation RecipeShopperAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize recipeBookViewController;
@synthesize recipeBasketViewController;
@synthesize onlineShopViewController;
@synthesize onlineBasketViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DataManager initialiseAll];
    	
	[DataManager addNumRecipesObserver:self];
	
    /* add the tab bar controller's view to the window and display */
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];

    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"numRecipes"]) {
		NSNumber *numRecipes = [change objectForKey:NSKeyValueChangeNewKey];
		
		[[tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%d", [numRecipes intValue]]];
		
		if ([numRecipes intValue] == 0) {
			[[tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:NULL];
		}
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [DataManager uninitialiseAll];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[recipeBookViewController release];
	[recipeBasketViewController release];
	[onlineShopViewController release];
	[onlineBasketViewController release];
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

