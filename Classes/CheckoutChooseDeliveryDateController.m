//
//  CheckoutChooseDeliveryDate.m
//  RecipeShopper
//
//  Created by User on 7/20/10.
//  Copyright 2010 Assent Software. All rights reserved.
//

#import "CheckoutChooseDeliveryDateController.h"
#import "APIDeliverylot.h"

#define SCROLL_VIEW_MAX_HEIGHT 624.0f

@implementation CheckoutChooseDeliveryDateController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[deliveryDatePicker reloadAllComponents];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Add Tesco logo to nav bar
	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	//Add delegate and data source for uipickerview
	[deliveryDatePicker setDelegate:self];
	[deliveryDatePicker setDataSource:self];
	
	//Initialise globals
	collatedDayMonthDeliverySlots = [[NSMutableArray alloc] init];
	dayMonthTimeSlotReference = [[NSMutableDictionary alloc] init]; 
	dayMonthYearSlotReference = [[NSMutableDictionary alloc] init];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 60;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	switch (component) {
		case 0:
			return [collatedDayMonthDeliverySlots objectAtIndex:row];
			break;
		case 1:
			return @"19:00";
			break;
		case 2:
			return @"2009";
			break;
		default:
			return @"";
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	switch (component) {
		case 0:
			return 150;
			break;
		case 1:
			return 85;
			break;
		case 2:
			return 85;
			break;
		default:
			return 0;
	}
}


#pragma mark -
#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*) pickerView {
	return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	switch (component) {
		case 0:
			return [collatedDayMonthDeliverySlots count];
			break;
		case 1:
			return 10;
			break;
		case 2:
			return 2;
			break;
		default:
			return 0;
	}
}


#pragma mark -
#pragma mark IBActions and Additional

-(IBAction) proceedToCheckoutAction:(id)sender{
	
}

-(void) processDeliverySlots:(NSArray*) deliverySlots {
	//Reset globals
	[collatedDayMonthDeliverySlots removeAllObjects];
	[dayMonthTimeSlotReference removeAllObjects];
	[dayMonthYearSlotReference removeAllObjects];
	
	//Sanity check
	if ([deliverySlots count] == 0) {
		return;
	}
	
	//Setup all the date formatters
	NSDateFormatter *dayMonthformatter = [[NSDateFormatter alloc] init];
	[dayMonthformatter setDateFormat:@"ccc MMM dd"];
	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setDateFormat:@"hh:mm"];
	NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
	[yearFormatter setDateFormat:@"YYYY"];
	
	//Setup for loop
	NSString *firstYear = [yearFormatter stringFromDate:[[deliverySlots objectAtIndex:0] deliverySlotStartDate]];
	NSString *lastSeenDay = [dayMonthformatter stringFromDate:[[deliverySlots objectAtIndex:0] deliverySlotStartDate]];
	[dayMonthYearSlotReference setValue:firstYear forKey:lastSeenDay];
	NSMutableArray *timesForDate = [NSMutableArray array];
	
	for (APIDeliverySlot *apiDeliverySlot in deliverySlots) {
		NSString *thisDay = [dayMonthformatter stringFromDate:[apiDeliverySlot deliverySlotStartDate]];
		//If we have come across a new day...
		if (![thisDay isEqualToString:lastSeenDay]) {
			//Add new item to collated list if its new day
			[collatedDayMonthDeliverySlots addObject:thisDay];
			//Create a reference from lastSeenDay to timesForDate
			[dayMonthTimeSlotReference setValue:timesForDate forKey:thisDay];
			//Create new timesForDate Array
			timesForDate = [NSMutableArray array];
			//Create a year reference for this day
			NSString *thisYear = [yearFormatter stringFromDate:[apiDeliverySlot deliverySlotStartDate]];
			[dayMonthYearSlotReference setValue:thisYear forKey:thisDay];
		}else {
			//If its same day add new time to reference dict
			NSString *timeSlot = [timeFormatter stringFromDate:[apiDeliverySlot deliverySlotStartDate]];
			[timesForDate addObject:timeSlot];
		}

		lastSeenDay = thisDay;
	}
			 
	//Release all the date formatters
	 [dayMonthformatter release];
	 [timeFormatter release];
	 [yearFormatter release];
}
										
#pragma mark -

- (void)dealloc {
	[availableDeliverySlots release];
    [super dealloc];
}


@end
