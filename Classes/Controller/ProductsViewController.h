//
//  ProductsViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 13/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *productsView;
	
	@private 
	NSMutableArray *products;
	NSString *productShelf;
}

@property (nonatomic, retain) NSString *productShelf;

- (void)loadProducts:(NSString *)shelf;

@end
