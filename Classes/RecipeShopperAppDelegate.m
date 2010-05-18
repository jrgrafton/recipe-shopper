//
//  RecipeShopperAppDelegate.m
//  RecipeShopper
//
//  Created by James Grafton on 5/6/10.
//  Copyright Asset Enhancing Technologies 2010. All rights reserved.
//

#import "RecipeShopperAppDelegate.h"
#import "HomeViewNavController.h"

@implementation RecipeShopperAppDelegate

@synthesize window;
@synthesize rootController;
@synthesize homeViewNavController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:rootController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
	[homeViewNavController release];
	[rootController release];
    [window release];
    [super dealloc];
}


@end
