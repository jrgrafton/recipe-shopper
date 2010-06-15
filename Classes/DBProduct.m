//
//  DBProduct.m
//  RecipeShopper
//
//  Created by James Grafton on 6/15/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "DBProduct.h"

@interface DBProduct ()
@property (readwrite,assign) NSInteger productBaseID;
@property (readwrite,copy) NSString *productName;
@property (readwrite,copy) NSString *productPrice;
@property (readwrite,copy) UIImage *productIcon;
@property (readwrite,copy) NSDate *lastUpdated;
@end

@implementation DBProduct

@synthesize productBaseID,productName,productPrice,productIcon,lastUpdated;

- (id)initWithProductID: (NSInteger)inProductBaseID andProductName:(NSString*)inProductName 
		andProductPrice:(NSString*)inProductPrice andProductIcon:(UIImage*)inProductIcon 
		 andLastUpdated:(NSDate*)inLastUpdated{
	
	if (self = [super init]) {
		[self setProductBaseID:inProductBaseID];
		[self setProductName:inProductName];
		[self setProductPrice:inProductPrice];
		[self setProductIcon:inProductIcon];
		[self setLastUpdated:inLastUpdated];
	}
	return self;
	
}

- (void)dealloc {
	[productName release];
	[productPrice release];
	[productIcon release];
	[lastUpdated release];
	[super dealloc];
}


@end
