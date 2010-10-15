//
//  ProductsViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 13/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductsViewController : UITableViewController {
	IBOutlet UITableView *productsView;
@private NSMutableArray *products;
}

@property (nonatomic, retain) NSString *shelf;

@end
