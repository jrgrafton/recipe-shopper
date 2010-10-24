//
//  UITableViewCellFactory.h
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Recipe.h"
#import "Product.h"

@interface UITableViewCellFactory : NSObject {

}

/* create cells with a recipe in each cell */
+ (void)createRecipeTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withRecipe:(Recipe *)recipe isHeader:(BOOL)isHeader;

/* create cells with a Tesco.com product in each cell */
+ (NSArray *)createProductTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withProduct:(Product *)product andQuantity:(NSNumber *)quantity forShoppingList:(BOOL)forShoppingList isHeader:(BOOL)isHeader;

/* create cells for total table sections */
+ (void)createTotalTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withNameValuePair:(NSArray *)nameValuePair isHeader:(BOOL)isHeader;

@end
