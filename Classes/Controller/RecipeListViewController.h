//
//  RecipeListViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeViewController.h"
#import "DataManager.h"

@interface RecipeListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIWebViewDelegate> {
	IBOutlet UITableView *recipeListView;
	
@private
	DataManager *dataManager;
	NSArray *recipes;
	NSString *categoryName;
	NSDictionary *extendedNameMappings;
}

- (void)loadRecipesForCategory:(NSString *)category;

@property (nonatomic, retain) RecipeViewController *recipeViewController;

@end
