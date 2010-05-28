//
//  HomeTableViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 5/18/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeStoreTableViewController;
@class CommonSpecificRecipeViewController;

@interface HomeTableViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITableView *homeTableView;
	HomeStoreTableViewController *homeStoreTableViewController;
	CommonSpecificRecipeViewController *commonSpecificRecipeViewController;
	
	NSArray *recipeHistory;
}

@property (readwrite,copy) NSArray *recipeHistory;
@property (nonatomic,retain) HomeStoreTableViewController *homeStoreTableViewController;
@property (nonatomic,retain) CommonSpecificRecipeViewController *commonSpecificRecipeViewController;

@end
