//
//  RecipeShopperAppDelegate.h
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright Assentec 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface RecipeShopperAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	IBOutlet UINavigationController *homeViewNavController;
	IBOutlet UINavigationController *onlineShopViewNavController;
	IBOutlet UINavigationController *checkoutViewNavController;
@private
	UIImageView *splashView;
	DataManager *dataManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *homeViewNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *onlineShopViewNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *checkoutViewNavController;

@end
