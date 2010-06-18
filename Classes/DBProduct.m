//
//  DBProduct.m
//  RecipeShopper
//
//  Created by James Grafton on 6/15/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "DBProduct.h"

@interface DBProduct ()
@property (readwrite,copy) NSNumber *productBaseID;
@property (readwrite,copy) NSString *productName;
@property (readwrite,copy) NSString *productPrice;
@property (readwrite,copy) UIImage *productIcon;
@property (readwrite,copy) NSDate *lastUpdated;
@property (readwrite,assign) BOOL userAdded;
@end

@implementation DBProduct

@synthesize productBaseID,productName,productPrice,productIcon,lastUpdated,userAdded;


- (BOOL)isEqual:(id)anObject{
	if (![anObject isKindOfClass:[DBProduct class]]) return NO;
	
	return [[anObject productBaseID]intValue] == [productBaseID intValue];
}

- (NSUInteger)hash{
	return [productBaseID intValue];
}

-(id) copyWithZone: (NSZone *) zone{
	DBProduct *productCopy = [[DBProduct allocWithZone:zone] initWithProductID:productBaseID andProductName:productName
														  andProductPrice:productPrice andProductIcon:productIcon
														   andLastUpdated:lastUpdated andUserAdded:userAdded];
	return productCopy;	
}

- (id)initWithProductID: (NSNumber*)inProductBaseID andProductName:(NSString*)inProductName 
		andProductPrice:(NSString*)inProductPrice andProductIcon:(UIImage*)inProductIcon 
		 andLastUpdated:(NSDate*)inLastUpdated andUserAdded:(BOOL)inUserAdded{
	
	if (self = [super init]) {
		[self setProductBaseID:inProductBaseID];
		[self setProductName:inProductName];
		[self setProductPrice:inProductPrice];
		[self setProductIcon:inProductIcon];
		[self setLastUpdated:inLastUpdated];
		[self setUserAdded:inUserAdded];
	}
	return self;
	
}

- (void)dealloc {
	[productBaseID release];
	[productName release];
	[productPrice release];
	[productIcon release];
	[lastUpdated release];
	[super dealloc];
}


@end
