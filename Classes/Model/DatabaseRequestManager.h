//
//  DatabaseRequestManager.h
//  RecipeShopper
//
//  Created by Simon Barnett on 06/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Recipe.h"

@interface DatabaseRequestManager : NSObject {

}

- (id)init;
- (NSString *)getUserPreference:(NSString *)prefName;
- (void)setUserPreference:(NSString *)prefName andValue:(NSString *)prefValue;
- (NSArray *)getAllRecipesInCategory:(NSString *)categoryName;
- (void)fetchExtendedDataForRecipe:(Recipe *)recipe;
- (void)addRecipeToHistory:(NSNumber *)recipeID;
- (NSArray *)getRecentRecipes;
- (NSArray *)createProductsFromProductBaseIDs:(NSDictionary *)productBaseIDList;

@end
