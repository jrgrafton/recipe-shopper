//
//  RecipeShopperAppDelegate.h
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright Assentec 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeShopperAppDelegate : NSObject <UIApplicationDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *homeViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *onlineShopViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *checkoutViewController;

@end
