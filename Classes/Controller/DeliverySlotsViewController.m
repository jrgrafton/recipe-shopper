//
//  DeliverySlotsViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 17/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "DeliverySlotsViewController.h"
#import "DataManager.h"
#import "LogManager.h"

#define DELIVERY_INFO_TYPE_TAG 1
#define DELIVERY_INFO_DETAILS_TAG 2
					
@interface DeliverySlotsViewController()

- (void)reloadDeliveryInfo;
- (void)transitionToCheckout:(id)sender;
- (void)verifyDeliverySlot;

@end

@implementation DeliverySlotsViewController

- (void)loadDeliveryDates {
	deliveryDates = [[DataManager getDeliveryDates] retain];
	sortedDeliveryDatesArray = [[NSMutableArray arrayWithArray:[deliveryDates allKeys]] retain];
	[sortedDeliveryDatesArray sortUsingSelector:@selector(compare:)];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[deliveryInfoView setBackgroundColor: [UIColor clearColor]];
	
	/* ensure table can't be selected */
	[deliveryInfoView setAllowsSelection:NO];
		
	/* add checkout button */
	UIBarButtonItem *checkoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Checkout" style:UIBarButtonItemStyleBordered target:self action:@selector(transitionToCheckout:)];
	self.navigationItem.rightBarButtonItem = checkoutButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	/* reset the date picker and delivery info */
	[deliverySlotPickerView selectRow:0 inComponent:0 animated:FALSE];
	[deliverySlotPickerView selectRow:0 inComponent:1 animated:FALSE];
	[deliverySlotPickerView reloadAllComponents];
	[self reloadDeliveryInfo];
}

- (void)transitionToCheckout:(id)sender {
	[DataManager showOverlayView:[[self view] window]];
	[DataManager setOverlayLabelText:@"Booking delivery slot"];
	[DataManager showActivityIndicator];
	
	[NSThread detachNewThreadSelector:@selector(verifyDeliverySlot) toTarget:self withObject:nil];
}

#pragma mark -
#pragma mark UIAlertView responders

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([[alertView title] isEqualToString:@"Success"]) {
		//User wishes to proceed to payment screen
		NSURL *url = [NSURL URLWithString:@"http://www.tesco.com/groceries/checkout/default.aspx?ui=iphone"];
		
		if (![[UIApplication sharedApplication] openURL:url]){
			[LogManager log:@"Unable to open Tesco.com payment page" withLevel:LOG_ERROR fromClass:@"DeliverySlotsViewController"];
		}
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DeliveryInfoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /* create a cell for this row's delivery info */
	if (cell == nil) {
		/* load the delivery info cell nib */
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"DeliveryInfoCell" owner:self options:nil];
		
        for (id viewElement in bundle) {
			if ([viewElement isKindOfClass:[UITableViewCell class]])
				cell = (UITableViewCell *)viewElement;
		}
    }
	
	NSString *deliveryInfoType;
	NSString *deliveryInfoDetails;
	
	if ([indexPath row] == 0) {
		deliveryInfoType = @"Delivery Date";
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"EEEE MMMM d"];
		deliveryInfoDetails = [dateFormatter stringFromDate:[selectedDeliverySlot deliverySlotDate]];
		[dateFormatter release];
	} else if ([indexPath row] == 1) {
		deliveryInfoType = @"Delivery Time";
		NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setTimeStyle:NSDateFormatterShortStyle];
		NSString *deliveryStart = [timeFormatter stringFromDate:[selectedDeliverySlot deliverySlotStartTime]];
		NSString *deliveryEnd = [timeFormatter stringFromDate:[selectedDeliverySlot deliverySlotEndTime]];
		[timeFormatter release];
		deliveryInfoDetails = [NSString stringWithFormat:@"%@ - %@", deliveryStart, deliveryEnd];
	} else if ([indexPath row] == 2) {
		deliveryInfoType = @"Delivery Cost";
		deliveryInfoDetails = [NSString stringWithFormat:@"£%.2f", [[selectedDeliverySlot deliverySlotCost] floatValue]];
	}
	
	UILabel *label = (UILabel *)[cell viewWithTag:DELIVERY_INFO_TYPE_TAG];
	[label setText:deliveryInfoType];
	
	label = (UILabel *)[cell viewWithTag:DELIVERY_INFO_DETAILS_TAG];
    [label setText:deliveryInfoDetails];
	
    return cell;
}

#pragma mark -
#pragma mark Picker View data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	NSInteger numberOfRows;
	
	if (component == 0) {
		/* date component */
		numberOfRows = [deliveryDates count];
	} else {
		/* time component */
		NSInteger selectedDate = [pickerView selectedRowInComponent:0];
		numberOfRows = [[deliveryDates objectForKey:[sortedDeliveryDatesArray objectAtIndex:selectedDate]] count];
	}
	
	return numberOfRows;
}

#pragma mark -
#pragma mark Picker View delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (component == 0) {
		/* if user has changed the delivery date, we need to update the delivery times */
		[deliverySlotPickerView selectRow:0 inComponent:1 animated:TRUE];
		[deliverySlotPickerView reloadComponent:1];
	}
	
	/* refresh the delivery info */
	[self reloadDeliveryInfo];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 60;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 60.0)] autorelease];
	[label setTextAlignment:UITextAlignmentCenter];
	
	if (component == 0) {
		[label setFont:[UIFont boldSystemFontOfSize:14]];
		[label setNumberOfLines:2];
		[label setLineBreakMode:UILineBreakModeWordWrap];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"EEEE\nMMMM d"];
		[label setText:[dateFormatter stringFromDate:[sortedDeliveryDatesArray objectAtIndex:row]]];
		[dateFormatter release];
	} else {
		[label setFont:[UIFont boldSystemFontOfSize:12]];
		NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setTimeStyle:NSDateFormatterShortStyle];
		NSDate *selectedDate = [sortedDeliveryDatesArray objectAtIndex:[pickerView selectedRowInComponent:0]];
		NSDictionary *timesToSlots = [deliveryDates objectForKey:selectedDate];
		NSMutableArray *sortedDeliveryTimesArray = [NSMutableArray arrayWithArray:[timesToSlots allKeys]];
		[sortedDeliveryTimesArray sortUsingSelector:@selector(compare:)];
		
		DeliverySlot *deliverySlot = [timesToSlots objectForKey:[sortedDeliveryTimesArray objectAtIndex:row]];
		
		[label setText:[NSString stringWithFormat:@"%@ - %@", [timeFormatter stringFromDate:[deliverySlot deliverySlotStartTime]], [timeFormatter stringFromDate:[deliverySlot deliverySlotEndTime]]]];
		[timeFormatter release];
	}
	
	return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	CGFloat width;
	
	if (component == 0) {
		width = 120;
	} else {
		width = 120;
	}
	
	return width;
}

#pragma mark -
#pragma mark Private methods

- (void)reloadDeliveryInfo {
	NSString *selectedDate = [sortedDeliveryDatesArray objectAtIndex:[deliverySlotPickerView selectedRowInComponent:0]];
	NSDictionary *deliveryTimeToSlot = [deliveryDates objectForKey:selectedDate];
	NSMutableArray *sortedDeliveryTimesArray = [NSMutableArray arrayWithArray:[deliveryTimeToSlot allKeys]];
	[sortedDeliveryTimesArray sortUsingSelector:@selector(compare:)];
	
	NSDate *selectedTime = [sortedDeliveryTimesArray objectAtIndex:[deliverySlotPickerView selectedRowInComponent:1]];
	selectedDeliverySlot = [deliveryTimeToSlot objectForKey:selectedTime];
	 
	/* reload the delivery info */
	[deliveryInfoView reloadData];
}

- (void)verifyDeliverySlot {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString* error = NULL;
	if ([DataManager chooseDeliverySlot:[selectedDeliverySlot deliverySlotID] returningError:&error] == YES) {
		UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You will now be transferred to Tesco.com for payment processing" delegate:self cancelButtonTitle:@"Proceed" otherButtonTitles:nil];
		[successAlert show];
		[successAlert release];
	} else {
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
	}
			
	[DataManager hideOverlayView];
	
	[pool release];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

