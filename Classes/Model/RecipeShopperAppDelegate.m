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
- (void)loginFailed;
- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)transitionToOnlineShop;
- (void)transitionToCheckout;
@end

@implementation RecipeShopperAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize homeViewNavController;
@synthesize onlineShopViewNavController;
@synthesize checkoutViewNavController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	dataManager = [DataManager getInstance];
	
	/* Session key has to be generated in background so that iOS doesn't kill app due to UI unresponsiveness */
	[NSThread detachNewThreadSelector:@selector(createAnonymousSessionKey) toTarget:dataManager withObject:nil];
	
	/* Give Session key time to generate */
	[NSThread sleepForTimeInterval:1];
	
	/* Try and do a cheeky cached load of product departments (Will automagically get queue'd behind session key request */
	[NSThread detachNewThreadSelector:@selector(getDepartments) toTarget:dataManager withObject:nil];
	
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
	if (((viewController == [theTabBarController.viewControllers objectAtIndex:2]) || (viewController == [theTabBarController.viewControllers objectAtIndex:3])) && ([dataManager phoneIsOnline] == NO)) {
		UIAlertView *offlineAlert = [[UIAlertView alloc] initWithTitle:@"Offline mode" message:@"Feature unavailable offline" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return NO;
	} else if ((viewController == [theTabBarController.viewControllers objectAtIndex:2]) && ([dataManager loggedIn] == NO)) {
		[dataManager requestLoginToStore];
		
		/* add ourselves as an observer for logged in messages so we can transition when the user has logged in */
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionToOnlineShop) name:@"LoggedIn" object:nil];
		
		/* add ourselves as an observer for login failed so we can prompt user */
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed) name:@"LoginFailed" object:nil];
		
		/* add ourselves as an observer for login cancelled so we can remove ourselves as observer */
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCancelled) name:@"LoginCancelled" object:nil];
		
		/* and make sure we don't transition yet */
		return NO;
	} else if (viewController == [theTabBarController.viewControllers objectAtIndex:3]) {
		/* Always ensure we pop back to root controller when selecting checkout tab */
		[checkoutViewNavController popToRootViewControllerAnimated:FALSE];
		
		if ([dataManager loggedIn] == NO) {
			/* Don't select tab until user is authenticated */
			[dataManager requestLoginToStore];
			
			/* add ourselves as an observer for logged in messages so we can transition when the user has logged in */
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transitionToCheckout) name:@"LoggedIn" object:nil];
			
			/* add ourselves as an observer for login failed so we can prompt user */
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed) name:@"LoginFailed" object:nil];
			
			/* add ourselves as an observer for login cancelled so we can remove ourselves as observer */
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCancelled) name:@"LoginCancelled" object:nil];
			
			/* and make sure we don't transition yet */
			return NO;
		}
	}
	
	return YES;
}

#pragma mark -
#pragma mark Private methods

- (void)loginFailed {
	UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Login failed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
	[successAlert show];
	[successAlert release];
}

- (void)loginCancelled {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[splashView removeFromSuperview];
	[splashView release];
}

- (void)transitionToOnlineShop {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	/* transition to the online shop view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate tabBarController] setSelectedViewController:[tabBarController.viewControllers objectAtIndex:2]];
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
	if ([alertView title] == @"Error" && buttonIndex == 0) {
		/* user has selected cancel so remove all observers (they will be re-added if they select tab again) */
		[[NSNotificationCenter defaultCenter] removeObserver: self];
	} else if ([alertView title] == @"Error" && buttonIndex == 1) {
		/* user has selected retry so leave observers as they are and ask for login again */
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
	[homeViewNavController release];
	[onlineShopViewNavController release];
	[checkoutViewNavController release];
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

