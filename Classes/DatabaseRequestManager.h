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
- (NSString*) fetchUserPreference: (NSString*) key;
- (id)init;

@end
