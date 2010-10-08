//
//  OnlineShopShelvesViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 12/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductsViewController.h"

@interface ShelvesViewController : UITableViewController {

	IBOutlet UITableView *shelvesView;
@private NSArray *shelves;
	
}

@property (nonatomic, retain) ProductsViewController *productsViewController;

- (void)loadShelvesForAisle:(NSString *)aisle;

@end
