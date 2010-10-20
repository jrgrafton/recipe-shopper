//
//  HomeViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 13/10/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeBasketViewController.h"
#import "RecipeHistoryViewController.h"
#import "RecipeCategoryViewController.h"

@interface HomeViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIButton *loginButton;
	IBOutlet UIWebView *webView;
	IBOutlet UILabel *greetingLabel;
	IBOutlet UIButton *logoutButton;
	IBOutlet UISwitch *offlineModeSwitch;
}

@property (nonatomic, retain) RecipeBasketViewController *recipeBasketViewController;
@property (nonatomic, retain) RecipeHistoryViewController *recipeHistoryViewController;
@property (nonatomic, retain) RecipeCategoryViewController *recipeCategoryViewController;

- (IBAction)login:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)transitionToRecipeCategoryView:(id)sender;
- (IBAction)transitionToRecipeBasketView:(id)sender;
- (IBAction)transitionToRecipeHistoryView:(id)sender;
- (IBAction)offlineModeValueChanged:(id)sender;

@end
