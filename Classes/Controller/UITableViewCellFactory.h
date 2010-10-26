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

/* create cells for online shopping department section */
+ (void)createOnlineShopDepartmentTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withDepartmentName:(NSString *)departmentName withIcon:(UIImage *)iconImage isHeader:(BOOL)isHeader;

/* create cells for online shopping department aisle section */
+ (void)createOnlineShopAisleTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withAisleName:(NSString *)aisleName isHeader:(BOOL)isHeader;

/* create cells for online shopping department category shelf section */
+ (void)createOnlineShopShelfTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withShelfName:(NSString *)shelfName isHeader:(BOOL)isHeader;

/* create cells for delivery slot sections */
+ (void)createDeliverySlotTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withNameValuePair:(NSArray *)nameValuePair isHeader:(BOOL)isHeader;

@end
