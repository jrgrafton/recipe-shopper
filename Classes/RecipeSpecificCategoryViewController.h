//
//  RecipeSpecificCategoryViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 6/8/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonSpecificRecipeViewController.h"


@interface RecipeSpecificCategoryViewController : UITableViewController <UIWebViewDelegate> {

	IBOutlet UITableView *categoryTableView;
	CommonSpecificRecipeViewController *commonSpecificRecipeViewController;
	
	@private
	NSArray *recipes;
	NSString *categoryName;

}

-(void) loadRecipesForCategory:(NSString*) categoryString;

@property (nonatomic,retain) CommonSpecificRecipeViewController *commonSpecificRecipeViewController;

@end
