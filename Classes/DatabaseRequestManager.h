//
//  DatabaseManager.h
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DatabaseRequestManager : NSObject {

}

- (NSArray*) fetchLastPurchasedRecipes: (NSInteger)count;
- (NSArray*)fetchAllRecipesInCategory: (NSString*) category;
- (NSArray*)fetchProductsFromIDs: (NSArray*) productIDs;
- (NSString*) fetchUserPreference: (NSString*) key;
- (void)putUserPreference: (NSString*)key andValue:(NSString*) value;
- (void)putRecipeHistory: (NSInteger)recipeID;
- (id)init;

@end
