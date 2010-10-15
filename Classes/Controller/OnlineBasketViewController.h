//
//  OnlineBasketViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 13/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeliverySlotsViewController.h"

@interface OnlineBasketViewController : UITableViewController <UITabBarControllerDelegate, UIAlertViewDelegate> {
	
	IBOutlet UITableView *onlineBasketView;
@private BOOL waitingForAPI;
	
}

@property (nonatomic, retain) DeliverySlotsViewController *deliverySlotsViewController;
@property (nonatomic, retain) NSString *basketPrice;
@property (nonatomic, retain) NSString *basketSavings;

- (IBAction)transitionToDeliverySlotView:(id)sender;
- (void)updateOnlineBasketDetails;

@end
