//
//  DBProduct.h
//  RecipeShopper
//
//  Created by James Grafton on 6/15/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBProduct : NSObject {
	NSNumber *productBaseID;
	NSString *productName;
	NSString *productPrice;
	UIImage *productIcon;
	NSDate *lastUpdated;
	BOOL userAdded;
}

@property (readonly,copy) NSNumber *productBaseID;
@property (readonly,copy) NSString *productName;
@property (readonly,copy) NSString *productPrice;
@property (readonly,copy) UIImage *productIcon;
@property (readonly,copy) NSDate *lastUpdated;
@property (readonly,assign) BOOL userAdded;

//So we can be stored in NSDictionary
- (BOOL)isEqual:(id)anObject;
- (NSUInteger)hash;
-(id) copyWithZone: (NSZone *) zone;

- (id)initWithProductID: (NSNumber*)inProductBaseID andProductName:(NSString*)inProductName 
	   andProductPrice:(NSString*)inProductPrice andProductIcon:(UIImage*)inProductIcon 
		 andLastUpdated:(NSDate*)inLastUpdated andUserAdded:(BOOL)inUserAdded; 
@end