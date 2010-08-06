//
//  UITableCellFactory.h
//  RecipeShopper
//
//  Created by User on 8/3/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRecipe.h"
#import "DBProduct.h"

@interface UITableViewCellFactory : NSObject {

}

+ (void)createRecipeTableCell:(UITableViewCell**)cellReference withIdentifier:(NSString*)cellIdentifier usingRecipeObject:(DBRecipe*)recipeObject;
+ (NSArray*)createProductTableCell:(UITableViewCell**)cellReference withIdentifier:(NSString*)cellIdentifier usingProductObject:(DBProduct*)productObject;

@end
