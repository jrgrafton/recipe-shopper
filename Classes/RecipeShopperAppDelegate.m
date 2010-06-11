//
//  RecipeShopperAppDelegate.m
//  RecipeShopper
//
//  Created by James Grafton on 5/6/10.
//  Copyright Asset Enhancing Technologies 2010. All rights reserved.
//

#import "RecipeShopperAppDelegate.h"
#import "AllViewsNavController.h"
#import "DataManager.h"
#import "LogManager.h"

@implementation RecipeShopperAppDelegate

@synthesize window;
@synthesize rootController;
@synthesize homeViewNavController;
@synthesize recipeCategoryViewNavController;
@synthesize checkoutViewNavController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	//Initialise the DataManager request managers
	[DataManager initialiseAll];
	
    // Override point for customization after app launch    
    [window addSubview:rootController.view];
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	//DeInitialise the DataManager request managers
	[DataManager deinitialiseAll];
}


- (void)dealloc {
	[homeViewNavController release];
	[recipeCategoryViewNavController release];
	[checkoutViewNavController release];
	[rootController release];
    [window release];
    [super dealloc];
}


@end
