//
//  DataManager.h
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRecipe.h"

@interface DataManager : NSObject {
	
}

//Publicly available data aquisition
+ (NSArray*)fetchLastPurchasedRecipes: (NSInteger) count;
+ (NSString*)fetchUserPreference: (NSString*) key;
+ (NSString*)fetchUserDocumentsPath;
+ (BOOL)fileExistsInUserDocuments: (NSString*) fileName;

//Initialisation and deinitialisation procedures
+ (void)initRequestManagers;
+ (void)deInitRequestManagers;

@end
