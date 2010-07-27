//
//  HomeViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 5/18/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeStoreViewController;
@class CommonSpecificRecipeViewController;

@interface HomeViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITableView *homeTableView;
	HomeStoreViewController *homeStoreViewController;
	CommonSpecificRecipeViewController *commonSpecificRecipeViewController;
	
	@private
	NSArray *recipeHistory;
}

@property (readwrite,copy) NSArray *recipeHistory;
@property (nonatomic,retain) HomeStoreViewController *homeStoreViewController;
@property (nonatomic,retain) CommonSpecificRecipeViewController *commonSpecificRecipeViewController;

@end
