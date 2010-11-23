//
//  RecipeShopperAppDelegate.m
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright Assentec 2010. All rights reserved.
//

#import "RecipeShopperAppDelegate.h"
#import "DataManager.h"

@interface RecipeShopperAppDelegate()
- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end

@implementation RecipeShopperAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize homeViewController;
@synthesize onlineShopViewController;
@synthesize checkoutViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	dataManager = [DataManager getInstance];
	
	[dataManager addShoppingListProductsObserver:self];
	[dataManager addBasketProductsObserver:self];
	
    /* add the tab bar controller's view to the window and display */
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];

	/* animate the splash screen's disappearance */
	splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];
	splashView.image = [UIImage imageNamed:@"Default.png"];
	[window addSubview:splashView];
	[window bringSubviewToFront:splashView];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:2.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:window cache:YES];
	[UIView setAnimationDelegate:self]; 
	[UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
	splashView.alpha = 0.0;
	splashView.frame = CGRectMake(-60, -85, 440, 635);
	[UIView commitAnimations];
	
    return YES;
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[splashView removeFromSuperview];
	[splashView release];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"shoppingListProducts"]) {
		NSNumber *shoppingListProducts = [change objectForKey:NSKeyValueChangeNewKey];
		
		[[tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%d", [shoppingListProducts intValue]]];
		
		if ([shoppingListProducts intValue] == 0) {
			[[tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:NULL];
		}
    } else if ([keyPath isEqual:@"basketProducts"]) {
		NSNumber *basketProducts = [change objectForKey:NSKeyValueChangeNewKey];
		
		[[tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%d", [basketProducts intValue]]];
		
		if ([basketProducts intValue] == 0) {
			[[tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:NULL];
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
    [dataManager uninitialiseAll];
}

#pragma mark -
#pragma mark Tab Bar Controller delegate

- (BOOL)tabBarController:(UITabBarController *)theTabBarController shouldSelectViewController:(UIViewController *)viewController {
	if (([dataManager phoneIsOnline] == NO) && ((viewController == [theTabBarController.viewControllers objectAtIndex:2]) || (viewController == [theTabBarController.viewControllers objectAtIndex:3]))) {
		UIAlertView *offlineAlert = [[UIAlertView alloc] initWithTitle:@"Offline mode" message:@"Feature unavailable offline" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return NO;
	} else if (([dataManager loggedIn] == NO) && (viewController == [theTabBarController.viewControllers objectAtIndex:3])) {
		[dataManager requestLoginToStore];
		
		/* add ourselves as an observer for logged in messages so we can transition when the user has logged in */
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionToCheckout) name:@"LoggedIn" object:nil];
		
		/* add ourselves as an observer for login failed so we can prompt user */
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed) name:@"LoginFailed" object:nil];
		
		/* and make sure we don't transition yet */
		return NO;
	}
	
	return YES;
}

- (void)loginFailed {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Login failed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
	[successAlert show];
	[successAlert release];
}

- (void)transitionToCheckout {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	/* transition to the online basket view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate tabBarController] setSelectedViewController:[tabBarController.viewControllers objectAtIndex:3]];
}

#pragma mark -
#pragma mark UIAlertView responders

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	//In case user clicks cancel on login
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	if ([alertView title] == @"Error" && buttonIndex == 1) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionToCheckout) name:@"LoggedIn" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed) name:@"LoginFailed" object:nil];
		[dataManager requestLoginToStore];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[homeViewController release];
	[onlineShopViewController release];
	[checkoutViewController release];
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

