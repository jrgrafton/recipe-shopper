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
-(NSString*) getDaySuffixForDate:(NSDate*)date;
-(void) reloadDeliveryInfo;
-(void) proceedToCheckoutAction:(id)sender;
-(void) showLoadingOverlay;
-(void) hideLoadingOverlay;
-(void) verifyOrder;
-(void) verifyOrderError:(NSString*) error;
-(void) chooseDeliverySlot:(APIDeliverySlot*) deliverySlot;
-(void) chooseDeliverySlotError:(NSString*) error;
-(void) transitionToCheckout:(NSDate*) slotExpireyDate;
@end

@implementation CheckoutChooseDeliveryDateController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		//Initialise all member variables
		availableDeliverySlots = [[NSMutableArray alloc] init];
		collatedDayMonthDeliverySlots = [[NSMutableArray alloc] init];
		dayMonthTimeSlotReference = [[NSMutableDictionary alloc] init];
		dayMonthYearSlotReference = [[NSMutableDictionary alloc] init];
		pickerDateSlotReference = [[NSMutableDictionary alloc] init];
		deliveryTimeSlotString = [[NSString alloc] init];
		deliveryCostString = [[NSString alloc] init];
		totalCostString = [[NSString alloc] init];
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	//Make sure date picker is reset and UILabels are reloaded
	[deliveryDatePicker  selectRow:0 inComponent:0 animated:FALSE];
	[deliveryDatePicker  selectRow:0 inComponent:1 animated:FALSE];
	[deliveryDatePicker reloadAllComponents];
	[self reloadDeliveryInfo];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Add Tesco logo to nav bar
	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	//Ensure table can't be selected
	[deliveryInformationTableView setAllowsSelection:NO];
	
	//Add right navigation button
	//Add product add button to top right corner
	UIBarButtonItem *checkoutButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Checkout" style:UIBarButtonItemStyleBordered target:self action:@selector(proceedToCheckoutAction:)];
	
	self.navigationItem.rightBarButtonItem = checkoutButton;
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
	if (component == 0) {
		//If we are changing the day month column refresh the others...
		[deliveryDatePicker  selectRow:0 inComponent:1 animated:TRUE];
		[deliveryDatePicker reloadComponent:1];
	}
	
	//Refresh UILabels
	[self reloadDeliveryInfo];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 60;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSString *dayMonthReferenceKey = [collatedDayMonthDeliverySlots objectAtIndex: [pickerView selectedRowInComponent:0]];
	
	switch (component) {
		case 0:
			return [collatedDayMonthDeliverySlots objectAtIndex: row];
			break;
		case 1:
			return [[dayMonthTimeSlotReference objectForKey:dayMonthReferenceKey] objectAtIndex:row];
			break;
		default:
			return @"";
	}
	
	return @"";
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	switch (component) {
		case 0:
			return 130;
			break;
		case 1:
			return 105;
			break;
		default:
			return 0;
	}
	
	return 0;
}


#pragma mark -
#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*) pickerView {
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	//Need this since [pickerView selectedRowInComponent:0] leads to recursive call
	if (component == 0) {
		return [collatedDayMonthDeliverySlots count];
	}
	
	NSString *dayMonthReferenceKey = [collatedDayMonthDeliverySlots objectAtIndex: [pickerView selectedRowInComponent:0]];
	
	switch (component) {
		case 1:
			return [[dayMonthTimeSlotReference objectForKey:dayMonthReferenceKey] count];
			break;
		case 2:
			return 1; //A day belongs to only one year!
			break;
		default:
			return 1;
	}
	
	return 1;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return @"";
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
	return 42;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,130,35)];
	[infoLabel setFont:[UIFont systemFontOfSize:14]];
	[infoLabel setTextAlignment: UITextAlignmentRight];
	
	switch ([indexPath row]) {
		case 0:
			[[cell textLabel] setText:@"Slot Time"];
			[infoLabel setText:deliveryTimeSlotString];
			break;
		case 1:
			[[cell textLabel] setText:@"Slot Cost"];
			[infoLabel setText:deliveryCostString];
			break;
		case 2:
			[[cell textLabel] setText:@"Total Cost"];
			[infoLabel setText:totalCostString];
			break;
		default:
			break;
	}
	
	//Having a view allows us to right pad UILabel
	UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0,0,140,35)];
	[accessoryView addSubview:infoLabel];
	[infoLabel release];
	
	[cell setAccessoryView:accessoryView];
	[accessoryView release];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

#pragma mark -
#pragma mark IBActions and Additional

-(void) proceedToCheckoutAction:(id)sender{
	//Grab referenced APIDeliverySlot object
	APIDeliverySlot *apiDeliverySlot = [self getImpliedDeliverySlotObject];
	[self showLoadingOverlay];
	
	//Detach thread to choose delivery slot
	[NSThread detachNewThreadSelector: @selector(chooseDeliverySlot:) toTarget:self withObject:apiDeliverySlot];
}

-(void) chooseDeliverySlot:(APIDeliverySlot*) deliverySlot {
	NSString *error = nil;
	
	if (![DataManager chooseDeliverySlot: deliverySlot returningError: &error]) {
		[self performSelectorOnMainThread:@selector(chooseDeliverySlotError:) withObject:error waitUntilDone:TRUE];
	}else {
		//Verify that entire order is OK before proceeding
		[self verifyOrder];
	}
}

-(void) chooseDeliverySlotError:(NSString*) error {
	//Show error
	UIAlertView *apiError = [[UIAlertView alloc] initWithTitle: @"Tesco API error" message: error delegate: nil cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
	[apiError show];
	[apiError release];
	[self hideLoadingOverlay];
}

-(void) verifyOrder{
	[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewLoadingText:) withObject:@"Verifying order..." waitUntilDone:FALSE];
	
	NSString *error = nil;
	NSDate* slotExpireyDate = [DataManager verifyOrder:&error];
	
	if (error != nil) {
		[self performSelectorOnMainThread:@selector(verifyOrderError:) withObject:error waitUntilDone:TRUE];
	}else {
		[self performSelectorOnMainThread:@selector(transitionToCheckout:) withObject:slotExpireyDate waitUntilDone:TRUE];
	}
}

-(void) verifyOrderError:(NSString*) error{
	//Show error
	UIAlertView *apiError = [[UIAlertView alloc] initWithTitle: @"Tesco API error" message: error delegate: nil cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
	[apiError show];
	[apiError release];
	[self hideLoadingOverlay];
}

-(void) transitionToCheckout:(NSDate*) slotExpireyDate {
	NSLocale *          enUSPOSIXLocale;
	enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setLocale:enUSPOSIXLocale];
	[df setDateFormat:@"hh:mma"];
	
	NSString *msg = [NSString stringWithFormat:@"Order slot reserved until %@",[df stringFromDate:slotExpireyDate]];
	UIAlertView *apiError = [[UIAlertView alloc] initWithTitle: @"Success" message: msg delegate: nil cancelButtonTitle: @"Proceed" otherButtonTitles: nil];
	[apiError show];
	[apiError release];
					
	[df release];
	[self hideLoadingOverlay];
	
	//TRANSITION TO CHECKOUT PAGE - WE ARE READY TO PAY!
	
	
	
}

-(NSString*) getDaySuffixForDate:(NSDate*) date {
	NSDateFormatter *monthDayFormatter = [[NSDateFormatter alloc] init];
	[monthDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[monthDayFormatter setDateFormat:@"d"];
	NSInteger dateDay = [[monthDayFormatter stringFromDate:date] intValue];      
	NSString *suffixString = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
	NSArray *suffixes = [suffixString componentsSeparatedByString: @"|"];
	[monthDayFormatter release];
	
	return [suffixes objectAtIndex:dateDay];
}


-(APIDeliverySlot*) getImpliedDeliverySlotObject {
	//Figure out indexes
	NSInteger selectedDayMonthIndex = [deliveryDatePicker selectedRowInComponent:0];
	NSInteger selectedTimeIndex = [deliveryDatePicker selectedRowInComponent:1];
	
	//Figure out strings
	NSString *dayMonthString = [collatedDayMonthDeliverySlots objectAtIndex:selectedDayMonthIndex];
	NSString *timeString = [[dayMonthTimeSlotReference objectForKey: dayMonthString] objectAtIndex:selectedTimeIndex];
	NSString *yearString = [dayMonthYearSlotReference objectForKey: dayMonthString];
	
	//Concatinate
	NSString *dateString = [NSString stringWithFormat:@"%@ %@ %@",dayMonthString,timeString,yearString];
	
	APIDeliverySlot* slot = [pickerDateSlotReference objectForKey:dateString];
	
	if (slot == nil) {
	#ifdef DEBUG
		NSLog(@"NULL APIDeliverySlot object for [%@]",dateString);
	#endif
	}
	
	//Grab referenced APIDeliverySlot object
	return slot;
}

-(void) reloadDeliveryInfo {
	APIDeliverySlot *apiDeliverySlot = [self getImpliedDeliverySlotObject];
	
	//Possibility of this function being called before UIPicker is instantiated
	if (apiDeliverySlot == nil) {
		return;
	}
	
	//Setup formatter for deliveryTimeLabel
	NSDateFormatter *deliveryLabelFormatter = [[NSDateFormatter alloc] init];
	[deliveryLabelFormatter setDateFormat:@"hh:mma"];
	NSString *firstHalfDeliveryDateString = [deliveryLabelFormatter stringFromDate:[apiDeliverySlot deliverySlotStartDate]]; 
	[deliveryLabelFormatter setDateFormat:@"hh:mma"];
	NSString *secondHalfDeliveryDateString = [deliveryLabelFormatter stringFromDate:[apiDeliverySlot deliverySlotEndDate]]; 
	
	//Update all delivery info fields
	[deliveryTimeSlotString release];
	[deliveryCostString release];
	[totalCostString release];
	
	deliveryTimeSlotString = [[NSString stringWithFormat:@"%@ - %@",firstHalfDeliveryDateString,secondHalfDeliveryDateString] retain];
	deliveryCostString = [[NSString stringWithFormat:@"£%.2f",[[apiDeliverySlot deliverySlotCost] floatValue]] retain];
	CGFloat totalCostFloat = [DataManager getTotalProductBasketCost] + [[apiDeliverySlot deliverySlotCost] floatValue];
	totalCostString = [[NSString stringWithFormat:@"£%.2f",totalCostFloat] retain];
	
	//Release formatter object
	[deliveryLabelFormatter release];
	
	//Reload table view
	[deliveryInformationTableView reloadData];
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
	//Release exisiting array
	[availableDeliverySlots release];
	
	//Take ownership of passed in array
	availableDeliverySlots = [deliverySlots retain];
	
	//Setup all the date formatters
	NSLocale *          enUSPOSIXLocale;
	enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
	
	NSDateFormatter *dayMonthformatter = [[NSDateFormatter alloc] init];
	[dayMonthformatter setLocale:enUSPOSIXLocale];
	[dayMonthformatter setDateFormat:@"ccc MMM d"];
	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setLocale:enUSPOSIXLocale];
	[timeFormatter setDateFormat:@"hh:mmaa"];
	NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
	[yearFormatter setLocale:enUSPOSIXLocale];
	[yearFormatter setDateFormat:@"YYYY"];
	
	//Setup for loop
	NSString *firstYearString = [yearFormatter stringFromDate:[[availableDeliverySlots objectAtIndex:0] deliverySlotStartDate]];
	NSString *lastSeenDayMonthString = [dayMonthformatter stringFromDate:[[availableDeliverySlots objectAtIndex:0] deliverySlotStartDate]];
	//lastSeenDayMonthString = [NSString stringWithFormat:@"%@%@",lastSeenDayMonthString,[self getDaySuffixForDate:[[availableDeliverySlots objectAtIndex:0] deliverySlotStartDate]]];
	[collatedDayMonthDeliverySlots addObject:lastSeenDayMonthString];
	[dayMonthYearSlotReference setValue:firstYearString forKey:lastSeenDayMonthString];
	NSMutableArray *timesForDayMonth = [NSMutableArray array];
	
	NSInteger index = 1;
	for (APIDeliverySlot *apiDeliverySlot in availableDeliverySlots) {
		NSString *dayMonthString = [dayMonthformatter stringFromDate:[apiDeliverySlot deliverySlotStartDate]];
		//Add day suffix
		//dayMonthString = [NSString stringWithFormat:@"%@%@",dayMonthString,[self getDaySuffixForDate:[apiDeliverySlot deliverySlotStartDate]]];
		
		NSString *timeString = [timeFormatter stringFromDate:[apiDeliverySlot deliverySlotStartDate]];
		NSString *yearString = [yearFormatter stringFromDate:[apiDeliverySlot deliverySlotStartDate]];
		
		NSString *collatedDateString = [NSString stringWithFormat:@"%@ %@ %@",dayMonthString,timeString,yearString];
		[pickerDateSlotReference setValue:apiDeliverySlot forKey:collatedDateString];
		
		//If we have come across a new day...
		if (![dayMonthString isEqualToString:lastSeenDayMonthString]) {
			//Add new item to collated list if its new day
			[collatedDayMonthDeliverySlots addObject:dayMonthString];
			//Create a reference from lastSeenDayMonthString to times for dayMonthArray
			[dayMonthTimeSlotReference setValue:timesForDayMonth forKey:lastSeenDayMonthString];
			//Create new timesForDate Array
			timesForDayMonth = [NSMutableArray array];
			//Create a year reference for this day
			[dayMonthYearSlotReference setValue:yearString forKey:lastSeenDayMonthString];
		}else if (index == [availableDeliverySlots count]) {
			//Make sure last day month is captured!
			[dayMonthTimeSlotReference setValue:timesForDayMonth forKey:dayMonthString];
			[dayMonthYearSlotReference setValue:yearString forKey:dayMonthString];
		}else {
			//If its same day add new time to reference dict
			[timesForDayMonth addObject:timeString];
		}
		lastSeenDayMonthString = dayMonthString;
		index++;
	}
	
	//Release all the date formatters
	[dayMonthformatter release];
	[timeFormatter release];
	[yearFormatter release];
}

-(void)showLoadingOverlay{
	loadingView = [LoadingView loadingViewInView:(UIView *)[self view] withText:@"Booking Slot..." 
										 andFont:[UIFont systemFontOfSize:16.0f] andFontColor:[UIColor grayColor]
								 andCornerRadius:0 andBackgroundColor:[UIColor colorWithRed:1.0 
																					  green:1.0 
																					   blue:1.0
																					  alpha:1.0]
								   andDrawStroke:FALSE];
}

-(void)hideLoadingOverlay{
	if(loadingView != nil){
		[loadingView removeView];
		loadingView = nil;
	}
}

#pragma mark -

- (void)dealloc {
	[availableDeliverySlots release];
	[collatedDayMonthDeliverySlots release];
	[dayMonthTimeSlotReference release];
	[dayMonthYearSlotReference release];
	[pickerDateSlotReference release];
	[deliveryTimeSlotString release];
	[deliveryCostString release];
	[totalCostString release];
	
    [super dealloc];
}


@end
