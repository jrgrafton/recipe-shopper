//
//  RecipeShopperAppDelegate.h
//  RecipeShopper
//
//  Created by James Grafton on 5/6/10.
//  Copyright Asset Enhancing Technologies 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AllViewsNavController;

@interface RecipeShopperAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet UITabBarController *rootController;
	IBOutlet AllViewsNavController *homeViewNavController;
	IBOutlet AllViewsNavController * recipeCategoryViewNavController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
@property (nonatomic, retain) IBOutlet AllViewsNavController *homeViewNavController;
@property (nonatomic, retain) IBOutlet AllViewsNavController *recipeCategoryViewNavController;

@end
