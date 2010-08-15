//
//  UITableCellFactory.h
//  RecipeShopper
//
//  Created by User on 8/3/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRecipe.h"
#import "DBProduct.h"

@interface UITableViewCellFactory : NSObject {

}

+ (void)createRecipeTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withRecipe:(DBRecipe *)recipe;
+ (NSArray*)createProductTableCell:(UITableViewCell **)cellReference withIdentifier:(NSString *)cellIdentifier withProduct:(DBProduct *)product;

@end
