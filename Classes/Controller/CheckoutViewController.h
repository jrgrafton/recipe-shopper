//
//  CheckoutViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 13/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeliverySlotsViewController.h"
#import "DataManager.h"

@interface CheckoutViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>  {
	IBOutlet UITableView *basketView;
	
@private 
	DataManager *dataManager;
	BOOL userWantsToProceed;
}

@property (nonatomic, retain) DeliverySlotsViewController *deliverySlotsViewController;

@property (nonatomic, retain) NSString *basketPrice;
@property (nonatomic, retain) NSString *basketSavings;
@property (nonatomic, retain) NSNumber *basketPoints;


- (IBAction)transitionToDeliverySlotView:(id)sender;

@end
