//
//  RecipeHistoryViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 13/10/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeViewController.h"
#import "DataManager.h"

@interface RecipeHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIWebViewDelegate, UIAlertViewDelegate> {
	IBOutlet UITableView *recipeHistoryView;
	
@private 
	DataManager *dataManager;
}

@property (nonatomic, retain) RecipeViewController *recipeViewController;
@property (nonatomic, retain) NSArray *recentRecipes;

@end
