//
//  ApplicationDataManager.h
//  RecipeShopper
//
//  Created by James Grafton on 6/8/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRecipe.h"


@interface ApplicationRequestManager : NSObject {
	NSMutableArray *shoppingBasket;
}

@property (nonatomic,retain) NSMutableArray *shoppingBasket;

- (id)init;
- (void)addRecipeToBasket: (DBRecipe*)recipe;
- (NSInteger)getBasketSize;

@end
