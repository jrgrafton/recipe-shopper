//
//  CheckoutChooseDeliveryDate.h
//  RecipeShopper
//
//  Created by User on 7/20/10.
//  Copyright 2010 Asset Enhancing Software Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"


@interface CheckoutChooseDeliveryDateController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate> {
	IBOutlet UIPickerView *deliveryDatePicker;
	IBOutlet UITableView *deliveryInformationTableView;
		
	@private
	//Delivery date information
	NSMutableArray* availableDeliverySlots;
	NSMutableArray* collatedDayMonthDeliverySlots;
	NSMutableDictionary *dayMonthTimeSlotReference;
	NSMutableDictionary *dayMonthYearSlotReference;
	
	//Used so that we can quickly lookup delivery slot objects from 
	NSMutableDictionary *pickerDateSlotReference;
	
	//Delivery information used by tableview
	NSString *deliveryTimeSlotString;
	NSString *deliveryCostString;
	NSString *totalCostString;
	
	//Loading view
	LoadingView *loadingView;
}

-(void) processDeliverySlots: (NSArray*) deliverySlots;

@end
