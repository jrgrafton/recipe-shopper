//
//  DBProduct.h
//  RecipeShopper
//
//  Created by James Grafton on 6/15/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBProduct : NSObject {
	NSInteger productBaseID;
	NSString *productName;
	NSString *productPrice;
	UIImage *productIcon;
	NSDate *lastUpdated;
}

@property (readonly,assign) NSInteger productBaseID;
@property (readonly,copy) NSString *productName;
@property (readonly,copy) NSString *productPrice;
@property (readonly,copy) UIImage *productIcon;
@property (readonly,copy) NSDate *lastUpdated;

- (id)initWithProductID: (NSInteger)inProductBaseID andProductName:(NSString*)inProductName 
	   andProductPrice:(NSString*)inProductPrice andProductIcon:(UIImage*)inProductIcon 
		 andLastUpdated:(NSDate*)inLastUpdated; 
@end
