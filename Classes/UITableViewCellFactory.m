//
//  UITableCellFactory.m
//  RecipeShopper
//
//  Created by User on 8/3/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "UITableViewCellFactory.h"
#import "DataManager.h"
#import "LogManager.h"

@implementation UITableViewCellFactory

#define PRODUCT_IMAGE_TAG 1
#define PRODUCT_PRICE_TAG 2
#define PRODUCT_TITLE_TAG 3
#define PRODUCT_OFFER_IMAGE_TAG 4
#define PRODUCT_OFFER_TAG 5
#define MINUS_BUTTON_TAG 6
#define COUNT_TAG 7
#define PLUS_BUTTON_TAG 8

+ (void)createRecipeTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withRecipe:(DBRecipe *)recipe{
	if (*cellReference == nil) {
        *cellReference = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
	
	UITableViewCell *cell = *cellReference;
	
	[[cell textLabel] setText: [[recipe recipeName] stringByReplacingOccurrencesOfString:@"Recipe for " withString:@""]];
	[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
	[[cell textLabel] setNumberOfLines:2];
	
	NSString *details = @"";
	if ([recipe serves] != nil) {
		details = [NSString stringWithFormat:@"Serves: %@",[recipe serves]];
	}
	[[cell detailTextLabel] setText:details];
	
	//Super size image and set scale to 2.0 so image looks sexy on retina displays
	UIImage * img = [[recipe iconLarge] resizedImage:CGSizeMake(150,150) interpolationQuality:kCGInterpolationHigh andScale:2.0];
	[[cell imageView] setImage: img];
	
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
}

+ (NSArray *)createProductTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withProduct:(DBProduct *)product {
	UILabel *label;
	UIImageView *image;
	UIButton *plusButton, *minusButton;
	
	// create an array of buttons references to be returned from function
	NSMutableArray *buttons = [[[NSMutableArray alloc] initWithCapacity:2] autorelease];
	
	if (*cellReference == nil) {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"ProductViewCell" owner:self options:nil];
		
        for (id viewElement in bundle) {
			if ([viewElement isKindOfClass:[UITableViewCell class]])
				*cellReference = (UITableViewCell *)viewElement;
		}
    }
	
	UITableViewCell *cell = *cellReference;
	
	image = (UIImageView *)[cell viewWithTag:PRODUCT_IMAGE_TAG];
	[image setImage:[product productIcon]];
	
	label = (UILabel *)[cell viewWithTag:PRODUCT_PRICE_TAG];
    [label setText:[NSString stringWithFormat:@"£%.2f", [[product productPrice] floatValue]]];
	
	label = (UILabel *)[cell viewWithTag:PRODUCT_TITLE_TAG];
    [label setText:[product productName]];
	
	image = (UIImageView *)[cell viewWithTag:PRODUCT_OFFER_IMAGE_TAG];
	[image setImage:[product productOfferIcon]];
	
	label = (UILabel *)[cell viewWithTag:PRODUCT_OFFER_TAG];
	[label setText:[product productOffer]];
	
	plusButton = (UIButton *)[cell viewWithTag:PLUS_BUTTON_TAG];
	[plusButton setTag:[[product productID] intValue]];
	[buttons insertObject:plusButton atIndex:0];
	
	label = (UILabel *)[cell viewWithTag:COUNT_TAG];
	minusButton = (UIButton *)[cell viewWithTag:MINUS_BUTTON_TAG];
	[minusButton setTag:[[product productID] intValue]];
	[buttons insertObject:minusButton atIndex:1];
	
	NSInteger productQuantity = [DataManager getCountForProduct:product];
	
	if (productQuantity > 0) {
		
		[label setText:[NSString stringWithFormat:@"%d in basket", productQuantity]];
	} else {
		[label removeFromSuperview];
		[minusButton removeFromSuperview];
	}

	return buttons;
}

@end
