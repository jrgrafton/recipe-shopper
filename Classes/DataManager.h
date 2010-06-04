//
//  DataManager.h
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DBRecipe.h"

@interface DataManager : NSObject <CLLocationManagerDelegate>{

}

//Publicly available data aquisition
//DB data
+ (NSArray*)fetchLastPurchasedRecipes: (NSInteger) count;
+ (NSString*)fetchUserPreference: (NSString*) key;
+ (NSString*)fetchUserDocumentsPath;

//iPhone SDK data
+ (BOOL)fileExistsInUserDocuments: (NSString*) fileName;
+ (BOOL)phoneIsOnline;
+ (NSArray*)getCurrentLatitudeLongitude;

//HTTP data
+ (NSArray*)fetchClosestStores: (NSArray*)latitudeLongitude andReturnUpToThisMany:(NSInteger) count;

//Initialisation and deinitialisation procedures
+ (void)initialiseAll;
+ (void)deinitialiseAll;

@end
