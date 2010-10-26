//
//  OnlineShopShelvesViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 12/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductsViewController.h"

@interface ShelvesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *shelvesView;
	@private NSMutableArray *shelves;
}

@property (nonatomic, retain) ProductsViewController *productsViewController;
@property (nonatomic, retain) NSString *aisle;

@end
