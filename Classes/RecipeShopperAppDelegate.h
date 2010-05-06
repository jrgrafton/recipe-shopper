//
//  RecipeShopperAppDelegate.h
//  RecipeShopper
//
//  Created by User on 5/6/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecipeShopperViewController;

@interface RecipeShopperAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RecipeShopperViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RecipeShopperViewController *viewController;

@end

