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

@interface HomeViewController : UIViewController {

}

@property (nonatomic, retain) RecipeBasketViewController *recipeBasketViewController;
@property (nonatomic, retain) RecipeHistoryViewController *recipeHistoryViewController;
@property (nonatomic, retain) RecipeCategoryViewController *recipeCategoryViewController;

- (IBAction)transitionToRecipeBasketView:(id)sender;
- (IBAction)transitionToRecipeHistoryView:(id)sender;
- (IBAction)transitionToRecipeCategoryView:(id)sender;

@end
