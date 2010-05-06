//
//  RecipeShopperAppDelegate.m
//  RecipeShopper
//
//  Created by User on 5/6/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RecipeShopperAppDelegate.h"
#import "RecipeShopperViewController.h"

@implementation RecipeShopperAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
