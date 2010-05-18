//
//  RecipeShopperAppDelegate.h
//  RecipeShopper
//
//  Created by James Grafton on 5/6/10.
//  Copyright Asset Enhancing Technologies 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeViewNavController;

@interface RecipeShopperAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet UITabBarController *rootController;
	IBOutlet HomeViewNavController *homeViewNavController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
@property (nonatomic, retain) IBOutlet HomeViewNavController *homeViewNavController;

@end
