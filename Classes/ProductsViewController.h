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

}

@property (nonatomic, retain) NSArray *products;

- (void)loadProductsForShelf:(NSString *)shelf;

@end
