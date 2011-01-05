//
//  RecipeCategoryViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright Assentec 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeListViewController.h"

/* Mapping from tag number from button to meaningful names */
typedef enum RecipeCategory
{
	CAKES = 0,
	BREAKFASTS = 1,
	DESSERTS = 2,
	DINNERS = 3,
	DRINKS = 4,
	LUNCHES = 5,
	MAINS = 6,
	PARTY = 7,
	SALADS = 8,
	SAUCES = 9,
	SNACKS = 10,
	SOUPS = 11,
	STARTERS = 12
} RecipeCategory;

@interface RecipeCategoryViewController : UIViewController {
	IBOutlet UIScrollView *recipeCategoryView;
	RecipeListViewController *recipeListViewController;
	
@private 
	NSDictionary *categoryMappings;
}

@property (nonatomic,retain) RecipeListViewController *recipeListViewController;

- (IBAction)categoryChosen:(id)sender;

@end
