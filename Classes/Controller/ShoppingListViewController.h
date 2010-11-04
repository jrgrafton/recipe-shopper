//
//  ShoppingListViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 10/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@interface ShoppingListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *productTableView;
	
@private
	DataManager *dataManager;
}

@property (nonatomic, retain) NSString *basketPrice;

@end