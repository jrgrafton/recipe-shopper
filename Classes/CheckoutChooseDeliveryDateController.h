//
//  CheckoutChooseDeliveryDate.h
//  RecipeShopper
//
//  Created by User on 7/20/10.
//  Copyright 2010 Assent Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CheckoutChooseDeliveryDateController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate> {
	IBOutlet UIButton *bookDeliverySlotButton;
	IBOutlet UIPickerView *deliveryDatePicker;
	
	IBOutlet UILabel *deliveryTimeLabel;
	IBOutlet UILabel *deliveryCostLabel;
	IBOutlet UILabel *totalCostLabel;
		
	@private
	NSArray* availableDeliverySlots;
	NSMutableArray* collatedDayMonthDeliverySlots;
	NSDictionary *dayMonthTimeYearSlotReference;
}

-(IBAction) proceedToCheckoutAction:(id)sender;
-(void) processDeliverySlots: (NSArray*) deliverySlots;

@end
