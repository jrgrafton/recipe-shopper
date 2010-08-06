//
//  RecipeCatagoryViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 6/7/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeSpecificCategoryViewController.h"

//Used to map tag name from button to meaningful numbers
typedef enum RecipeCategory
{
	BREAD_CAKES_BISCUITS = 0,
	BREAKFAST = 1,
	DESSERT = 2,
	DINNERS = 3,
	DRINKS = 4,
	LUNCHES = 5,
	MAIN = 6,
	PARTY_FOOD = 7,
	SALADS = 8,
	SAUCES = 9,
	SNACKS_SIDE_DISHES = 10,
	SOUPS = 11,
	STARTER = 12
} RecipeCategory;

@interface RecipeCategoryViewController : UIViewController {
	
	RecipeSpecificCategoryViewController *recipeSpecificCategoryViewController;
	IBOutlet UIScrollView *scrollView;
	
	@private
	NSDictionary *categoryMappings;
}

@property (nonatomic,retain) RecipeSpecificCategoryViewController *recipeSpecificCategoryViewController;

-(IBAction) categoryChosen:(id)sender;

@end
