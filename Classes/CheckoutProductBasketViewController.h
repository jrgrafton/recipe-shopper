//
//  CheckoutProductBasketViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 6/15/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CheckoutProductBasketViewController : UITableViewController {
	IBOutlet UITableView *productBasketTableView;
	
	UIView *footerView;
}

@end
