//
//  RecipeListViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeViewController.h"

@interface RecipeListViewController : UITableViewController <UIWebViewDelegate> {
    
	IBOutlet UITableView *recipeListView;
@private NSArray *recipes;
@private NSString *categoryName;
	
}

- (void)loadRecipesForCategory:(NSString *)category;

@property (nonatomic, retain) RecipeViewController *recipeViewController;

@end