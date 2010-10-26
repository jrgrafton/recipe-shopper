//
//  UITableViewCellFactory.m
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "UITableViewCellFactory.h"
#import "UIImage-Extended.h"

@implementation UITableViewCellFactory

//Disclosure offset is half header height + half disclosure height
#define DISCLOSURE_OFFSET 9 + 8

#define PRODUCT_IMAGE_TAG 1
#define PRODUCT_PRICE_TAG 2
#define PRODUCT_TITLE_TAG 3
#define PRODUCT_OFFER_IMAGE_TAG 4
#define PRODUCT_OFFER_TAG 5

#define RECIPE_IMAGE_TAG 1
#define RECIPE_TITLE_TAG 2
#define RECIPE_SERVES_TAG 3

#define MINUS_BUTTON_TAG 9
#define COUNT_TAG 10
#define PLUS_BUTTON_TAG 11

#define DEPARTMENTNAME_TAG 1
#define DEPARTMENTIMAGE_TAG 2

#define AISLENAME_TAG 1

#define SHELFNAME_TAG 1

#define TOTAL_KEY_TAG 1
#define TOTAL_VALUE_TAG 2

+ (void)createRecipeTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withRecipe:(Recipe *)recipe isHeader:(BOOL)isHeader {
	UILabel *label;
	UIImageView *image;
	
	if (*cellReference == nil) {
		/* load the recipe view cell nib */
        NSArray *bundle;
		UIImage *disclosureImage = [UIImage imageNamed:@"disclosure.png"];
		UIImageView *imageView = [[UIImageView alloc] initWithImage: disclosureImage];
		UIView *accessoryView;		
		
		if (isHeader) {
			bundle = [[NSBundle mainBundle] loadNibNamed:@"RecipeViewCellHeader" owner:self options:nil];
			accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [imageView frame].size.width,[imageView frame].size.height + DISCLOSURE_OFFSET)];
			[imageView setFrame:CGRectMake(0, DISCLOSURE_OFFSET, [imageView frame].size.width, [imageView frame].size.height)];
		}else{
			bundle = [[NSBundle mainBundle] loadNibNamed:@"RecipeViewCell" owner:self options:nil];
			accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [imageView frame].size.width,[imageView frame].size.height)];
		}
		
        for (id viewElement in bundle) {
			if ([viewElement isKindOfClass:[UITableViewCell class]])
				*cellReference = (UITableViewCell *)viewElement;
		}
		
		[accessoryView addSubview:imageView];
		[*cellReference setAccessoryView:accessoryView];
    }
	
	UITableViewCell *cell = *cellReference;
	
	image = (UIImageView *)[cell viewWithTag:RECIPE_IMAGE_TAG];
	[image setImage:[[recipe largeRecipeImage] resizedImage:CGSizeMake(150,150) interpolationQuality:kCGInterpolationHigh andScale:2.0]];
	
	label = (UILabel *)[cell viewWithTag:RECIPE_TITLE_TAG];
    [label setText:[[recipe recipeName] stringByReplacingOccurrencesOfString:@"Recipe for " withString:@""]];
	
	NSString *serves = @"";
	
	if ([recipe serves] != nil) {
		serves = [NSString stringWithFormat:@"Serves: %@", [recipe serves]];
	}
	
	label = (UILabel *)[cell viewWithTag:RECIPE_SERVES_TAG];
	[label setText:serves];
}

+ (NSArray *)createProductTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withProduct:(Product *)product andQuantity:(NSNumber *)quantity forShoppingList:(BOOL)forShoppingList isHeader:(BOOL)isHeader {
	UILabel *label;
	UIImageView *image;
	UIButton *plusButton, *minusButton;
	
	/* create an array of buttons references to be returned from function (for the plus and minus button) */
	NSMutableArray *buttons = [[[NSMutableArray alloc] initWithCapacity:2] autorelease];
	
	if (*cellReference == nil) {
		/* load the product view cell nib */
        NSArray *bundle;	
		
		if (isHeader) {
			bundle = [[NSBundle mainBundle] loadNibNamed:@"ProductViewCellHeader" owner:self options:nil];
		}else{
			bundle = [[NSBundle mainBundle] loadNibNamed:@"ProductViewCell" owner:self options:nil];
		}
		
        for (id viewElement in bundle) {
			if ([viewElement isKindOfClass:[UITableViewCell class]])
				*cellReference = (UITableViewCell *)viewElement;
		}
    }
	
	UITableViewCell *cell = *cellReference;
	
	/* set the various parts of the product view to the values for this particular product */
	image = (UIImageView *)[cell viewWithTag:PRODUCT_IMAGE_TAG];
	[image setImage:[product productImage]];
	
	label = (UILabel *)[cell viewWithTag:PRODUCT_PRICE_TAG];
    [label setText:[NSString stringWithFormat:@"£%.2f", [[product productPrice] floatValue]]];
	
	label = (UILabel *)[cell viewWithTag:PRODUCT_TITLE_TAG];
    [label setText:[product productName]];
	
	image = (UIImageView *)[cell viewWithTag:PRODUCT_OFFER_IMAGE_TAG];
	[image setImage:[product productOfferImage]];
	
	label = (UILabel *)[cell viewWithTag:PRODUCT_OFFER_TAG];
	[label setText:[product productOffer]];
	
	plusButton = (UIButton *)[cell viewWithTag:PLUS_BUTTON_TAG];
	[plusButton setTag:[[product productBaseID] intValue]];
	[buttons insertObject:plusButton atIndex:0];
	
	label = (UILabel *)[cell viewWithTag:COUNT_TAG];
	minusButton = (UIButton *)[cell viewWithTag:MINUS_BUTTON_TAG];
	[minusButton setTag:[[product productBaseID] intValue]];
	[buttons insertObject:minusButton atIndex:1];
	
	if ([quantity intValue] > 0) {
		if (forShoppingList == YES) {
			[label setText:[NSString stringWithFormat:@"%@ required", quantity]];
		} else {
			[label setText:[NSString stringWithFormat:@"%@ in basket", quantity]];
		}
	} else {
		[label removeFromSuperview];
		[minusButton removeFromSuperview];
	}
	
	/* return the plus and minus buttons */
	return buttons;
}

+ (void)createTotalTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withNameValuePair:(NSArray *)nameValuePair isHeader:(BOOL)isHeader {
	if (*cellReference == nil) {
		/* load the recipe view cell nib */
        NSArray *bundle;
		
		if (isHeader) {
			bundle = [[NSBundle mainBundle] loadNibNamed:@"TotalsCellHeader" owner:self options:nil];
		}else{
			bundle = [[NSBundle mainBundle] loadNibNamed:@"TotalsCell" owner:self options:nil];
		}
		
        for (id viewElement in bundle) {
			if ([viewElement isKindOfClass:[UITableViewCell class]])
				*cellReference = (UITableViewCell *)viewElement;
		}
		
	}
	
	UITableViewCell *cell = *cellReference;
	UILabel *keyLabel = (UILabel*)[cell viewWithTag:TOTAL_KEY_TAG];
	UILabel *valueLabel = (UILabel*)[cell viewWithTag:TOTAL_VALUE_TAG];
	[keyLabel setText:[nameValuePair objectAtIndex:0]];
	[valueLabel setText:[nameValuePair objectAtIndex:1]];
	
	return;
}


/* create cells for shopping section */
+ (void)createOnlineShopDepartmentTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withDepartmentName:(NSString *)departmentName withIcon:(UIImage *)iconImage isHeader:(BOOL)isHeader {
	/* Create a cell for this row's department name */
	if (*cellReference == nil) {
		/* load the product view cell nib */
		NSArray *bundle;
		
		if (isHeader) {
			bundle = [[NSBundle mainBundle] loadNibNamed:@"DepartmentCellHeader" owner:self options:nil];
		}else{
			bundle = [[NSBundle mainBundle] loadNibNamed:@"DepartmentCell" owner:self options:nil];
		}
		
        for (id viewElement in bundle) {
			if ([viewElement isKindOfClass:[UITableViewCell class]])
				*cellReference = (UITableViewCell *)viewElement;
		}
	}
	
	UITableViewCell *cell = *cellReference;
	
	UILabel *departmentNameLabel = (UILabel *)[cell viewWithTag:DEPARTMENTNAME_TAG];
    [departmentNameLabel setText:departmentName];
	
	UIImageView *departmentImage = (UIImageView *)[cell viewWithTag:DEPARTMENTIMAGE_TAG];
	[departmentImage setImage:iconImage];
	
	return;
}

+ (void)createOnlineShopAisleTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withAisleName:(NSString *)aisleName isHeader:(BOOL)isHeader {
	/* Create a cell for this row's department name */
	if (*cellReference == nil) {
		/* load the product view cell nib */
		NSArray *bundle;
		UIImage *disclosureImage = [UIImage imageNamed:@"disclosure.png"];
		UIImageView *imageView = [[UIImageView alloc] initWithImage: disclosureImage];
		UIView *accessoryView;
		
		if (isHeader) {
			bundle = [[NSBundle mainBundle] loadNibNamed:@"AislesCellHeader" owner:self options:nil];
			accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [imageView frame].size.width,[imageView frame].size.height + DISCLOSURE_OFFSET)];
			[imageView setFrame:CGRectMake(0, DISCLOSURE_OFFSET, [imageView frame].size.width, [imageView frame].size.height)];
		}else{
			bundle = [[NSBundle mainBundle] loadNibNamed:@"AislesCell" owner:self options:nil];
			accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [imageView frame].size.width,[imageView frame].size.height)];
		}
		
        for (id viewElement in bundle) {
			if ([viewElement isKindOfClass:[UITableViewCell class]])
				*cellReference = (UITableViewCell *)viewElement;
		}
		
		[accessoryView addSubview:imageView];
		[*cellReference setAccessoryView:accessoryView];
	}
	
	UITableViewCell *cell = *cellReference;
	
	UILabel *aisleNameLabel = (UILabel *)[cell viewWithTag:AISLENAME_TAG];
    [aisleNameLabel setText:aisleName];
	
	return;
}

+ (void)createOnlineShopShelfTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withShelfName:(NSString *)shelfName isHeader:(BOOL)isHeader {
	/* Create a cell for this row's department name */
	if (*cellReference == nil) {
		/* load the product view cell nib */
		NSArray *bundle;
		UIImage *disclosureImage = [UIImage imageNamed:@"disclosure.png"];
		UIImageView *imageView = [[UIImageView alloc] initWithImage: disclosureImage];
		UIView *accessoryView;
		
		if (isHeader) {
			bundle = [[NSBundle mainBundle] loadNibNamed:@"ShelvesCellHeader" owner:self options:nil];
			accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [imageView frame].size.width,[imageView frame].size.height + DISCLOSURE_OFFSET)];
			[imageView setFrame:CGRectMake(0, DISCLOSURE_OFFSET, [imageView frame].size.width, [imageView frame].size.height)];
		}else{
			bundle = [[NSBundle mainBundle] loadNibNamed:@"ShelvesCell" owner:self options:nil];
			accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [imageView frame].size.width,[imageView frame].size.height)];
		}
		
        for (id viewElement in bundle) {
			if ([viewElement isKindOfClass:[UITableViewCell class]])
				*cellReference = (UITableViewCell *)viewElement;
		}
		
		[accessoryView addSubview:imageView];
		[*cellReference setAccessoryView:accessoryView];
	}
	
	UITableViewCell *cell = *cellReference;
	
	UILabel *shelvesNameLabel = (UILabel *)[cell viewWithTag:SHELFNAME_TAG];
    [shelvesNameLabel setText:shelfName];
	
	return;
}

@end
