//
//  CheckoutChooseDeliveryDate.m
//  RecipeShopper
//
//  Created by User on 7/20/10.
//  Copyright 2010 Assent Software. All rights reserved.
//

#import "CheckoutChooseDeliveryDateController.h"
#import "APIDeliverySlot.h"
#import "DataManager.h"

@interface CheckoutChooseDeliveryDateController ()
//Private class functions
-(APIDeliverySlot*) getImpliedDeliverySlotObject;
@end

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
	[deliveryDatePicker  selectRow:0 inComponent:0 animated:FALSE];
	[deliveryDatePicker  selectRow:0 inComponent:1 animated:FALSE];
	[deliveryDatePicker  selectRow:0 inComponent:2 animated:FALSE];
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
	pickerDateSlotReference = [[NSMutableDictionary alloc] init];
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
	//If we are changing the day month column refresh the others...
	[deliveryDatePicker  selectRow:0 inComponent:1 animated:FALSE];
	[deliveryDatePicker  selectRow:0 inComponent:2 animated:FALSE];
	[deliveryDatePicker reloadComponent:1];
	[deliveryDatePicker reloadComponent:2];
	
	//And refresh UILabels
	APIDeliverySlot *apiDeliverySlot = [self getImpliedDeliverySlotObject];
	
	//Setup formatter for deliveryTimeLabel
	NSDateFormatter *deliveryLabelFormatter = [[NSDateFormatter alloc] init];
	[deliveryLabelFormatter setDateFormat:@"dd/MM/YYYY hh:mma"];
	NSString *firstHalfDeliveryDateString = [deliveryLabelFormatter stringFromDate:[apiDeliverySlot deliverySlotStartDate]]; 
	[deliveryLabelFormatter setDateFormat:@"hh:mma"];
	NSString *secondHalfDeliveryDateString = [deliveryLabelFormatter stringFromDate:[apiDeliverySlot deliverySlotEndDate]]; 
	
	//Update all label fields
	[deliveryTimeLabel setText:[NSString stringWithFormat:@"%@ - %@",firstHalfDeliveryDateString,secondHalfDeliveryDateString]];
	[deliveryCostLabel setText:[apiDeliverySlot deliverySlotCost]];
	CGFloat totalCost = [DataManager getTotalProductBasketCost] + [[apiDeliverySlot deliverySlotCost] floatValue];
	[totalCostLabel setText:[NSString stringWithFormat:@"£%.2f",totalCost]];
	
	//Release formatter object
	[deliveryLabelFormatter release];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 60;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSString *dayMonthReferenceKey = [collatedDayMonthDeliverySlots objectAtIndex: [pickerView selectedRowInComponent:0]];
	
	switch (component) {
		case 0:
			return dayMonthReferenceKey;
			break;
		case 1:
			return [[dayMonthTimeSlotReference objectForKey:dayMonthReferenceKey] objectAtIndex:row];
			break;
		case 2:
			return [[dayMonthYearSlotReference objectForKey:dayMonthReferenceKey] objectAtIndex:row];
			break;
		default:
			return @"";
	}
	
	return @"";
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
	NSString *dayMonthReferenceKey = [collatedDayMonthDeliverySlots objectAtIndex: [pickerView selectedRowInComponent:0]];
	
	switch (component) {
		case 0:
			return [collatedDayMonthDeliverySlots count];
			break;
		case 1:
			return [[dayMonthTimeSlotReference objectForKey:dayMonthReferenceKey] count];
			break;
		case 2:
			return [[dayMonthYearSlotReference objectForKey:dayMonthReferenceKey] count];
			break;
		default:
			return 0;
	}
}


#pragma mark -
#pragma mark IBActions and Additional

-(IBAction) proceedToCheckoutAction:(id)sender{
	//Grab referenced APIDeliverySlot object
	//APIDeliverySlot *apiDeliverySlot = [self getImpliedDeliverySlotObject];
}

-(APIDeliverySlot*) getImpliedDeliverySlotObject {
	//Figure out indexes
	NSInteger selectedDayMonthIndex = [deliveryDatePicker selectedRowInComponent:0];
	NSInteger selectedTimeIndex = [deliveryDatePicker selectedRowInComponent:1];
	NSInteger selectedYearIndex = [deliveryDatePicker selectedRowInComponent:2];
	
	//Figure out strings
	NSString *dayMonthString = [collatedDayMonthDeliverySlots objectAtIndex:selectedDayMonthIndex];
	NSString *timeString = [[dayMonthTimeSlotReference objectForKey: dayMonthString] objectAtIndex:selectedTimeIndex];
	NSString *yearString = [[dayMonthYearSlotReference objectForKey: dayMonthString] objectAtIndex:selectedYearIndex];
	
	//Concatinate
	NSString *dateString = [NSString stringWithFormat:@"%@ %@ %@",dayMonthString,timeString,yearString];
	
	//Grab referenced APIDeliverySlot object
	return [pickerDateSlotReference objectForKey:dateString];
}

-(void) processDeliverySlots:(NSArray*) deliverySlots {
	//Reset globals
	[collatedDayMonthDeliverySlots removeAllObjects];
	[dayMonthTimeSlotReference removeAllObjects];
	[dayMonthYearSlotReference removeAllObjects];
	[pickerDateSlotReference removeAllObjects];
	
	//Sanity check
	if ([deliverySlots count] == 0) {
		return;
	}
	
	//Setup all the date formatters
	NSDateFormatter *dayMonthformatter = [[NSDateFormatter alloc] init];
	[dayMonthformatter setDateFormat:@"ccc MMM dd"];
	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setDateFormat:@"HH:mm"];
	NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
	[yearFormatter setDateFormat:@"YYYY"];
	
	//Setup for loop
	NSString *firstYearString = [yearFormatter stringFromDate:[[deliverySlots objectAtIndex:0] deliverySlotStartDate]];
	NSString *lastSeenDayMonthString = [dayMonthformatter stringFromDate:[[deliverySlots objectAtIndex:0] deliverySlotStartDate]];
	[dayMonthYearSlotReference setValue:firstYearString forKey:lastSeenDayMonthString];
	NSMutableArray *timesForDayMonth = [NSMutableArray array];
	
	for (APIDeliverySlot *apiDeliverySlot in deliverySlots) {
		NSString *dayMonthString = [dayMonthformatter stringFromDate:[apiDeliverySlot deliverySlotStartDate]];
		NSString *timeString = [timeFormatter stringFromDate:[apiDeliverySlot deliverySlotStartDate]];
		NSString *yearString = [yearFormatter stringFromDate:[apiDeliverySlot deliverySlotStartDate]];
		
		NSString *collatedDateString = [NSString stringWithFormat:@"%@ %@ %@",dayMonthString,timeString,yearString];
		[pickerDateSlotReference setValue:apiDeliverySlot forKey:collatedDateString];
		
		//If we have come across a new day...
		if (![dayMonthString isEqualToString:lastSeenDayMonthString]) {
			//Add new item to collated list if its new day
			[collatedDayMonthDeliverySlots addObject:dayMonthString];
			//Create a reference from lastSeenDay to timesForDate
			[dayMonthTimeSlotReference setValue:timeString forKey:dayMonthString];
			//Create new timesForDate Array
			timesForDayMonth = [NSMutableArray array];
			//Create a year reference for this day
			[dayMonthYearSlotReference setValue:yearString forKey:dayMonthString];
		}else {
			//If its same day add new time to reference dict
			[timesForDayMonth addObject:timeString];
		}

		lastSeenDayMonthString = dayMonthString;
	}
			 
	//Release all the date formatters
	 [dayMonthformatter release];
	 [timeFormatter release];
	 [yearFormatter release];
}
										
#pragma mark -

- (void)dealloc {
	[availableDeliverySlots release];
	[collatedDayMonthDeliverySlots release];
	[dayMonthTimeSlotReference release];
	[dayMonthYearSlotReference release];
	[pickerDateSlotReference release];
    [super dealloc];
}


@end
