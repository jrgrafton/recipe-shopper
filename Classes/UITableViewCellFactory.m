//
//  UITableCellFactory.m
//  RecipeShopper
//
//  Created by User on 8/3/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import "UITableViewCellFactory.h"
#import "DataManager.h"

@implementation UITableViewCellFactory

+ (void)createRecipeTableCell:(UITableViewCell**)cellReference withIdentifier:(NSString*)cellIdentifier usingRecipeObject:(DBRecipe*)recipeObject{
	if (*cellReference == nil) {
        *cellReference = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
	
	UITableViewCell *cell = *cellReference;
	
	[[cell textLabel] setText: [[recipeObject recipeName] stringByReplacingOccurrencesOfString:@"Recipe for " withString:@""]];
	[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
	[[cell textLabel] setNumberOfLines:2];
	
	NSString *details = @"";
	if ([recipeObject serves] != nil) {
		details = [NSString stringWithFormat:@"Serves: %@",[recipeObject serves]];
	}
	[[cell detailTextLabel] setText:details];
	
	//Super size image and set scale to 2.0 so image looks sexy on retina displays
	UIImage * img = [[recipeObject iconLarge] resizedImage:CGSizeMake(150,150) interpolationQuality:kCGInterpolationHigh andScale:2.0];
	[[cell imageView] setImage: img];
	
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
}

+ (NSArray*)createProductTableCell:(UITableViewCell**)cellReference withIdentifier:(NSString*)cellIdentifier usingProductObject:(DBProduct*)productObject{
	//Array of buttons references to be returned from function
	NSMutableArray* buttons = [[[NSMutableArray alloc] initWithCapacity:2] autorelease];
	
	if (*cellReference == nil) {
        *cellReference = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
	
	UITableViewCell *cell = *cellReference;
	
	// and the count of how many are already in the basket
	NSInteger productQuantity = [DataManager getCountForProduct:productObject];
	
	// Set up the cell...
	[[cell textLabel] setText:[productObject productName]];
	[[cell textLabel] setNumberOfLines:4 ];
	[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12]];
	[[cell detailTextLabel] setText:[NSString stringWithFormat:@"£%.2f each", ([[productObject productPrice] floatValue])]];
	
	//Super size image and set scale to 2.0 so image looks sexy on retina displays
	UIImage * img = [[productObject productIcon] resizedImage:CGSizeMake(150,150) interpolationQuality:kCGInterpolationHigh andScale:2.0];
	[[cell imageView] setImage: img];
	
	// Create the accessoryView for everything to be inserted into
	UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0,0,95,120)];
	
	if (productQuantity != 0) {
		// Minus button
		UIButton *minusButton = [[UIButton alloc] initWithFrame:CGRectMake(0,38,44,44)];
		[minusButton setTag:[[productObject productBaseID] intValue]];
		UIImage *minusImage = [UIImage imageNamed:@"button_minus.png"];
		[minusButton setBackgroundImage:minusImage forState:UIControlStateNormal];
		
		[accessoryView addSubview:minusButton];
		[buttons addObject:minusButton];
		[minusButton release];
	}
	
	// Plus button
	UIButton *plusButton = [[UIButton alloc] initWithFrame:CGRectMake(40,38,44,44)];
	[plusButton setTag:[[productObject productBaseID] intValue]];
	UIImage *plusImage = [UIImage imageNamed:@"button_plus.png"];
	[plusButton setBackgroundImage:plusImage forState:UIControlStateNormal];
	
	[buttons insertObject:plusButton atIndex:0];
	[accessoryView addSubview:plusButton];
	[plusButton release];
	
	if (productQuantity != 0) {
		// Count label
		UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(4,80,78,14)];
		NSMutableString* basketString = [NSString stringWithFormat:@"%d in basket", productQuantity];
		[countLabel setText:basketString];
		[countLabel setFont:[UIFont boldSystemFontOfSize:11]];
		[countLabel setTextAlignment: UITextAlignmentCenter];
		
		[accessoryView addSubview:countLabel];
		[countLabel release];
	}
	
	// Finally add accessory view itself
	[cell setAccessoryView:accessoryView];
	
	// release memory
	[accessoryView release];
	
	return buttons;
}

@end
