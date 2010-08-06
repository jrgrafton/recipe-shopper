//
//  CheckoutProductBasketViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 6/15/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "CheckoutChooseDeliveryDateController.h"

@protocol PreviousViewControllerDelegate;

@protocol PreviousViewControllerDelegate
- (void)currentViewControllerDidFinish:(UIViewController *)controller;
@end

@interface CheckoutProductBasketViewController : UITableViewController <PreviousViewControllerDelegate,UIAlertViewDelegate> {
	IBOutlet UITableView *productBasketTableView;	
	UIView *footerView;
	CheckoutChooseDeliveryDateController *checkoutChooseDeliveryDateController;
	
	@private
	LoadingView *loadingView;
}

@property (nonatomic,retain) CheckoutChooseDeliveryDateController *checkoutChooseDeliveryDateController;

@end
