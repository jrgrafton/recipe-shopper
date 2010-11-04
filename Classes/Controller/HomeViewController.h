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
#import "DataManager.h"

@interface HomeViewController : UIViewController <UIAlertViewDelegate> {
	IBOutlet UIButton *loginButton;
	IBOutlet UIButton *logoutButton;
	IBOutlet UIButton *createAccountButton;
	IBOutlet UILabel *loggedInGreetingLabel;
	IBOutlet UILabel *loggedOutGreetingLabel;
	IBOutlet UISwitch *offlineModeSwitch;
	
@private 
	DataManager *dataManager;
}

@property (nonatomic, retain) RecipeBasketViewController *recipeBasketViewController;
@property (nonatomic, retain) RecipeHistoryViewController *recipeHistoryViewController;
@property (nonatomic, retain) RecipeCategoryViewController *recipeCategoryViewController;

- (IBAction)login:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)createAccount:(id)sender;
- (IBAction)transitionToRecipeCategoryView:(id)sender;
- (IBAction)transitionToRecipeBasketView:(id)sender;
- (IBAction)transitionToRecipeHistoryView:(id)sender;
- (IBAction)offlineModeValueChanged:(id)sender;

@end
